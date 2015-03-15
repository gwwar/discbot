# Description:
#  discbot will give you some help
#
# Commands:
#   @discbot help - shows all discbot commands

module.exports = (robot) ->

  robot.respond /help/i, (post, match) ->

    helpCommands = robot.getHelpCommands()

    if helpCommands.length > 0
      message = "@#{post.username}, I understand:\n\n#{helpCommands.join('\n')}"
      post.reply message
