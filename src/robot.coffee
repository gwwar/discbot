Post = require './post'
Q = require 'q'

class Listener

  constructor: ({@regex, @action}) ->

class Robot

  # filters - filters what we should listen to. e.g only category 9: {category: 9}
  constructor: ({@client, @brain, filters}) ->
    @interval = 60000 # one minute
    @failInterval = 300000 # five minutes
    @listeners = []
    @timeout = null
    @filters = filters or {}
    @lastDate = Date.now()

  # registers a new listener
  respond: (regex, action) ->
    @listeners.push new Listener({regex, action})

  # stops the event loop
  start: ->
    console.log 'Starting up discbot...'
    self = @
    @timeout = setTimeout(self.listen, @interval, self)

  stop: ->
    console.log 'Stopping discbot...'
    clearTimeout(@timeout)

  # listens for new notifications
  listen: (self) ->
    console.log 'checking for new notifications...'
    self.client.notifications().then((body) ->

      new_notifications = body.user_actions.filter (notification) ->
        if new Date(notification.created_at).valueOf() > self.lastDate
          for key, value of self.filters
            if notification[key] isnt value
              return false
          return true

      console.log "found #{new_notifications.length} new notifications"
      self.lastDate = Date.now()

      promises = []
      posts = []

      # unfortunately the notification doesn't have the full post, we need to fetch it
      for notification in new_notifications

        promises.push self.client.getPost({post_id: notification.post_id}).then (body) ->
          posts.push new Post({
            client: self.client
            username: body.username
            message: body.raw
            topic_id: body.topic_id
            category: body.category_id
            reply_to_post_number: body.post_number
          })

      Q.allSettled(promises).then ->
        for post in posts
          for listener in self.listeners
            match = post.match listener.regex
            if match?
              listener.action post, match

        self.timeout = setTimeout(self.listen, self.interval, self)


    ).fail((body) ->
      console.log 'fail', body
      self.timeout = setTimeout(self.listen, self.failInterval, self)
    )

module.exports = Robot

