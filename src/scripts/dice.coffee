# Description:
#  rolls some dice
#
# Commands:
#   @discbot roll d20 - roll a single 20 sided dice
#   @discbot roll 2d20 - roll two dice
#   @discbot roll 2d20+5 - roll two dice with a positive modifier
#   @discbot roll 2d20-5 - roll two dice with a negative modifier
#   @discbot roll d20 your extra text here - rolls and parrots back your extra text


lineRegex = /roll (\d?\d?)d(\d+)(\+|-)?(\d?)(.*?)$/i
rollDice = (post, match) ->

  dice = parseInt(match[1], 10) or 1
  sides = parseInt(match[2], 10) or 0
  modifier = match[3]
  modifierValue = parseInt(match[4], 10) or 0
  extraText = match[5].trim()
  message = ""

  if (0 < sides < 1000000) and (0 < dice < 100)
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

    if extraText.length > 1
      message += " #{extraText}"

    if rolls.length > 1
      message += " (#{rolls.join()})"

  return message


module.exports = (robot) ->

  robot.respond /roll (\d?\d?)d(\d+)(\+|-)?(\d?)(.*?)/i, (post, match) ->
    message = ""
    lines = post.message.split('\n')
    for line in lines
      if message.length>0
        message += '\n'
      match = line.match lineRegex
      if match?
        message += rollDice(post, match)

    if message.length>0
      post.reply message
    else
      post.reply "![disbot](/uploads/default/original/f/7/f78876fd43f77876a3e52e9e070dbf5414250b0d.gif)"
