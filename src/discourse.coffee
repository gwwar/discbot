request = require 'request'
Q = require 'q'
uuid = require 'node-uuid'


class Discourse

  constructor: ({@url, @username, @password}) ->

    @clientId = uuid.v4()
    @jar = request.jar()

    @r = request.defaults({
      jar : @jar
      headers : {
        'User-Agent' : 'MRT2 v 0.0.0'
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
          if body.errors?
            deferred.reject(body)
          else
            deferred.resolve(body)
        catch e
          deferred.reject(e)

    deferred.promise

  # performs a post and returns a promise that resolves to the error or body
  _post: (url, form) ->
    deferred = Q.defer()

    @r.post url, form: form, (error, response, body) ->

      if error?
        deferred.reject(error)
      else
        try
          body = JSON.parse(body)
          if body.errors?
            deferred.reject(body)
          else
            deferred.resolve(body)
        catch e
          deferred.reject(e)

    deferred.promise

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
  createTopic: ({title, message}) ->
    @loginPromise.then =>
      @_post "#{@url}/posts", {
        title
        raw: message
        is_warning: false
        archetype: 'regular'
      }

  # replies to a given topic
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

  notifications: ->
    @loginPromise.then =>
      # fetches 60 of the most recent replies or mentions to this username.
      # looking at the UserActionController we can't limit this to a smaller
      # chunk, so don't call this that often.
      @_get "#{@url}/user_actions.json?offset=0&username=#{@username}&filter=6,7"


module.exports = Discourse