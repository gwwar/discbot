# Description:
#  discbot will give you some help
#
# Commands:
#   @discbot help - shows all discbot commands

getHexDigit = ->
  Math.floor(Math.random() * 16).toString(16).toUpperCase()

buildHexColor = ->
  [0,0,0,0,0,0].map( ->
    getHexDigit()
  ).join( '' )

module.exports = (robot) ->

  robot.respond /help/i, (post, match) ->

    helpCommands = robot.getHelpCommands()

    if helpCommands.length > 0
      message = "@#{post.username}, I understand:\n\n#{helpCommands.join('\n')}\n\nYour special color today is `##{buildHexColor()}`"
      post.reply message
