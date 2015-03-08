# rolls some dice

module.exports = (robot) ->

  robot.respond /roll d(\d+)/i, (post, match) ->

    sides = match[1]
    if 0 < sides < 1000
      dice = [1..sides]
      roll = post.random dice

    if roll?
      # return a message!
      post.reply "@#{post.username}, the d#{sides} dice reads: #{roll}"