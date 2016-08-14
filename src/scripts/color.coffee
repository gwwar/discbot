# Description:
#  discbot will think of a special color
#
# Commands:
#   @discbot color - discbot will respond with a color

getHexDigit = ->
  Math.floor(Math.random() * 16).toString(16).toUpperCase()

buildHexColor = ->
  [0,0,0,0,0,0].map( ->
    getHexDigit()
  ).join( '' )

favoriteRegex = /favorite color/i

module.exports = (robot) ->

  robot.respond /color/i, (post, match) ->
    if post.message.match favoriteRegex
      post.reply 'My favorite color is chucknorris'
    else
      post .reply "@#{post.username}, what about the color: `##{buildHexColor()}`"
