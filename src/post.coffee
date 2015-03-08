# wrapper for a forum post
class Post

  constructor: ({@client, @username, @message, @topic_id, @category, @reply_to_post_number}) ->

  # given an array, returns one of the elements
  random: (chooseOne) ->
    if chooseOne? and chooseOne.length > 0
      chooseOne[Math.floor(Math.random() * chooseOne.length)]

  # returns a match or null, if we should respond to a given regex
  match: (regex) ->
    @message.match regex

  # responds with a given message
  reply: (message) ->
    @client.reply({
      message: message
      category: @category
      topic_id: @topic_id
      is_warning: false
      archetype: 'regular'
      reply_to_post_number: @reply_to_post_number
    })


module.exports =  Post