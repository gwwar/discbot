# Description:
#  discbot will say hello to you
#
# Commands:
#   @discbot hello - discbot will respond with a greeting

module.exports = (robot) ->

  greetings = [
    'Hello, @#name#. I am your friendly neighborhood discourse bot.'
    '@#name# stop trying to talk to me. I am a bot. The moderators may eat me.'
    'Greetings, @#name#. I am a bot. Would you like to see some of my wares? Oh drat. I don\'t have any yet. Check back when I get a brain.'
    'Hello, Human. Or would you like to be called @#name#?'
  ]

  robot.respond /hello/i, (post, match) ->
    greeting = post.random greetings
    greeting = greeting.replace '#name#', post.username

    # return a message!
    post.reply greeting
