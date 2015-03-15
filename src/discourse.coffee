request = require 'request'
Q = require 'q'
winston = require 'winston'


class Discourse

  constructor: ({@url, @username, @password}) ->

    @jar = request.jar()

    @r = request.defaults({
      jar : @jar
      headers : {
        'User-Agent' : 'Discbot v 0.0.0'
        'X-Requested-With': 'XMLHttpRequest'
      }
    })

    @csrfPromise = @_csrf()
    @loginPromise = @login()

  # performs a get and returns a promise that resolves to the error or body
  _get: (url) ->
    deferred = Q.defer()

    @r.get url, (error, response, body) =>

      if error?
        deferred.reject(error)
      else
        try
          body = JSON.parse(body)
          if body.error? or body.errors?
            deferred.reject(body)
          else
            deferred.resolve(body)
        catch e
          deferred.reject(e)

    promise = deferred.promise
    promise.fail (e) ->
      winston.error "get failed for #{url}, with reason:", e

    promise

  # performs a post and returns a promise that resolves to the error or body
  _post: (url, form) ->
    deferred = Q.defer()

    @r.post url, form: form, (error, response, body) ->
      if error?
        deferred.reject(error)
      else
        try
          body = JSON.parse(body)
          if body.error? or body.errors?
            deferred.reject(body)
          else
            deferred.resolve(body)
        catch e
          deferred.reject(e)

    promise = deferred.promise
    promise.fail (e) ->
      winston.error "post failed for #{url}, with reason:", e

    promise

  # returns a promise with the resolved csrf token
  _csrf: ->
    @_get("#{@url}/session/csrf").then (body) =>
      @csrf = body.csrf
      @r = @r.defaults({
        headers: {
          'X-CSRF-Token': @csrf
        }
      })

  # returns a promise with the login response
  login: ->
    @csrfPromise.then =>
      @_post "#{@url}/session", {login: @username, password: @password}

  # sends a private message
  pm: ({title, message, target_usernames}) ->
    @loginPromise.then =>
      @_post "#{@url}/posts", {
        raw: message
        title: title
        is_warning: false
        archetype: 'private_message'
        target_usernames
      }

  # creates a new topic, we generally shouldn't let the bot do that
  createTopic: ({title, message, category}) ->
    @loginPromise.then =>
      @_post "#{@url}/posts", {
        title
        raw: message
        category
        is_warning: false
        archetype: 'regular'
      }

  # replies to a given topic or pm
  reply: ({message, topic_id, category, reply_to_post_number}) ->
    @loginPromise.then =>
      @_post "#{@url}/posts", {
        raw: message
        category: category
        topic_id: topic_id
        is_warning: false
        archetype: 'regular'
        reply_to_post_number: reply_to_post_number
      }

  getPost: ({post_id}) ->
    @loginPromise.then =>
      @_get "#{@url}/posts/#{post_id}.json"

  getTopic: ({topic_id, slug}) ->
    @loginPromise.then =>
      @_get "#{@url}/t/#{slug}/#{topic_id}.json"

#  Filter values correspond to the following:
#  Discbot currently listens to responses, mentions, and received private messages
#
#  LIKE = 1
#  WAS_LIKED = 2
#  BOOKMARK = 3
#  NEW_TOPIC = 4
#  REPLY = 5
#  RESPONSE= 6
#  MENTION = 7
#  QUOTE = 9
#  EDIT = 11
#  NEW_PRIVATE_MESSAGE = 12
#  GOT_PRIVATE_MESSAGE = 13
  notifications: ->
    @loginPromise.then =>
      # fetches 60 of the most recent replies or mentions to this username.
      # looking at the UserActionController we can't limit this to a smaller
      # chunk, so don't call this that often.
      @_get "#{@url}/user_actions.json?offset=0&username=#{@username}&filter=6,7,13"


module.exports = Discourse