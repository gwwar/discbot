Post = require '../src/post'
Q = require 'q'

# mock test robot for testing our scripts

class TestRobot

  constructor: () ->
    @listeners = []
    @regex = null
    @action = null

  # simulates someone @mentioning the bot
  test: ({message, username}) ->

    username ?= "defaultname"

    deferred = Q.defer()

    post = new Post({
      client: {}
      username: username
      message: message
      topic_id: 1
      category: 1
      reply_to_post_number: 1
    })

    # override post reply
    post.reply = (message) ->
      deferred.resolve(message)

    match = post.match @regex
    if match
      @action(post, match)
    else
      deferred.reject(new Error("No match found!"))

    deferred.promise

  # some mock data
  getHelpCommands: ->
    return [
       "@discbot roll d20 - roll a single 20 sided dice"
       "@discbot roll 2d20 - roll two dice"
    ]

  respond: (regex, action) ->
    @regex = regex
    @action = action


module.exports = TestRobot

