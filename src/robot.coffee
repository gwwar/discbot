Post = require './post'
Q = require 'q'
winston = require 'winston'
fs = require('fs')
Path = require('path')

class Listener

  constructor: ({@regex, @action}) ->

class Robot

  # filters - filters what we should listen to. e.g only category 9: {category: 9}
  constructor: ({@client, filters}) ->
    @interval = 60000 # one minute
    @failInterval = 300000 # five minutes
    @listeners = []
    @timeout = null
    @filters = filters or {}
    @lastDate = Date.now()
    @helpCommands = {}

  # registers a new listener
  respond: (regex, action) ->
    @listeners.push new Listener({regex, action})

  # stops the event loop
  start: ->
    self = @
    @timeout = setTimeout(self.listen, @interval, self)

    winston.info "\n
      ██████╗ ██╗███████╗ ██████╗██████╗  ██████╗ ████████╗\n
      ██╔══██╗██║██╔════╝██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝\n
      ██║  ██║██║███████╗██║     ██████╔╝██║   ██║   ██║\n
      ██║  ██║██║╚════██║██║     ██╔══██╗██║   ██║   ██║\n
      ██████╔╝██║███████║╚██████╗██████╔╝╚██████╔╝   ██║\n
      ╚═════╝ ╚═╝╚══════╝ ╚═════╝╚═════╝  ╚═════╝    ╚═╝\n
    "


  stop: ->
    clearTimeout(@timeout)
    winston.info "\n
    ██████╗ ██╗   ██╗███████╗\n
    ██╔══██╗╚██╗ ██╔╝██╔════╝\n
    ██████╔╝ ╚████╔╝ █████╗  \n
    ██╔══██╗  ╚██╔╝  ██╔══╝  \n
    ██████╔╝   ██║   ███████╗\n
    ╚═════╝    ╚═╝   ╚══════╝\n
                             "

  # parses a file and adds a help command
  addHelpCommand: (key, path) ->
    parent = module.parent
    parentFile = parent.filename
    parentDir = Path.dirname(parentFile)

    path = Path.resolve parentDir, path

    self = @
    self.helpCommands[key] = []
    body = fs.readFileSync path, 'utf-8'
    lines = body.split '\n'
    lines.forEach (line) ->
      if line.match /^#\W+@discbot/
        line = "    "+line.replace('#', '').trim()
        line = line.replace('discbot', self.client.username)
        self.helpCommands[key].push(line)

  # returns all the associated help information
  getHelpCommands: (key) ->
    if key?
      return @helpCommands[key]
    else
      allCommands = []
      for key, value of @helpCommands
        allCommands = allCommands.concat(value)
      return allCommands

  # listens for new notifications
  listen: (self) ->
    winston.info 'checking for new notifications...'
    self.client.notifications().then((body) ->

      new_notifications = body.user_actions.filter (notification) ->
        if new Date(notification.created_at).valueOf() > self.lastDate
          # don't filter if this is a private message
          if notification.action_type isnt 13
            for key, value of self.filters
              if notification[key] isnt value
                return false
          return true

      winston.info "found #{new_notifications.length} new notifications"
      self.lastDate = Date.now()

      promises = []
      posts = []

      # unfortunately the notification doesn't have the full post, we need to fetch it
      for notification in new_notifications

        if notification.post_id?
          promises.push self.client.getPost({post_id: notification.post_id}).then (body) ->

            posts.push new Post({
              client: self.client
              username: body.username
              message: body.raw
              topic_id: body.topic_id
              category: body.category_id
              reply_to_post_number: body.post_number
            })
        else if notification.slug? and notification.topic_id?
          #TODO: work around the fact that the first pm has a null post_id for some reason
          winston.info 'Attempted to speak to bot in first PM', notification

      Q.allSettled(promises).then ->
        for post in posts
          for listener in self.listeners
            match = post.match listener.regex
            if match?
              listener.action post, match

        self.timeout = setTimeout(self.listen, self.interval, self)


    ).fail((body) ->
      winston.error "failed to fetch notifications, #{body}"
      self.timeout = setTimeout(self.listen, self.failInterval, self)
    )

module.exports = Robot

