Discourse = require '../src/discourse'
should = require('chai').should()
faker = require 'faker'

url = process.env.MRT2_URL or 'http://localhost:3000'
username = process.env.MRT2_USERNAME
password = process.env.MRT2_PASSWORD
testuser = process.env.MRT2_TESTUSER # another user account you own

xdescribe 'Discourse', ->
  {discourse} = {}

  before ->
    discourse = new Discourse({
      url
      username
      password
    })

  it 'environment variables for the integration test are set', ->
    unless url? and username? and password?
      throw new Error("Please set up environment variables for this integration test.
        You should only run this against a discourse instance you own.")

  it 'creates a new discourse client with a url, username and password', ->

    discourse.url.should.equal url
    discourse.username.should.equal username
    discourse.password.should.equal password
    discourse.clientId.length.should.equal 36

  it 'can login', ->
    discourse.loginPromise.then((body) ->
      body.user.username.should.equal username
    ).fail (body) ->
      console.log body
      throw new Error("Cannot Log in")

  it 'can see latest notifications', ->
    discourse.notifications().fail (body) ->
      console.log body
      throw new Error("Cannot see latest notifications")

  xit 'can send a pm', ->

    title = faker.lorem.sentences(1)
    message = faker.lorem.sentences(5)

    discourse.pm({title: title, message: message, target_usernames: testuser }).fail (body) ->
      console.log body
      throw new Error("Cannot send a pm")

  xit 'can create a topic and add a reply', ->
      discourse.reply({
        message
        topic_id: 11
        category: 1
        reply_to_post_number: 2
      }).then (body) ->
        if body.errors
          console.log body.errors
          throw new Error("Failed to post")



