# Description:
#  rolls some dice
#
# Commands:
#   @discbot roll d20 - roll a single 20 sided dice
#   @discbot roll 2d20 - roll two dice
#   @discbot roll 2d20+5 - roll two dice with a positive modifier
#   @discbot roll 2d20-5 - roll two dice with a negative modifier

module.exports = (robot) ->

  robot.respond /roll (\d?)d(\d+)(\+|-)?(\d?)/i, (post, match) ->

    dice = parseInt(match[1], 10) or 1
    sides = parseInt(match[2], 10) or 0
    modifier = match[3]
    modifierValue = parseInt(match[4], 10) or 0

    if (0 < sides < 1000000) and (0 < dice < 10)
      rolls = [1..dice]
      rolls = rolls.map ->
        Math.ceil(Math.random()*sides)

    if rolls?
      sum = rolls.reduce (a,b) -> a+b

      modifierString = ''
      if modifier?
        if modifier is '+'
          sum += modifierValue
        else if modifier is '-'
          sum -= modifierValue

        modifierString = "#{modifier}#{modifierValue}"

      # only show # of dice if > 1
      dice = if dice > 1 then dice else ''

      message = "@#{post.username} the #{dice}d#{sides}#{modifierString} dice reads: #{sum}"

      if rolls.length > 1
        message += " (#{rolls.join()})"

      # return a message!
      post.reply message