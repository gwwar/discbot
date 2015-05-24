Discourse = require '../src/discourse'
expect = require('chai').expect
faker = require 'faker'

url = process.env.DISCBOT_URL or 'http://localhost:3000'
username = process.env.DISCBOT_USERNAME
password = process.env.DISCBOT_PASSWORD
testuser = process.env.DISCBOT_TESTUSER # another user account you own

# remove this x to run this integration test. Beware! You should only run this against a discourse instance you own.
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
    expect(discourse.url).to.equal url
    expect(discourse.username).to.equal username
    expect(discourse.password).to.equal password

  it 'can login', ->
    discourse.loginPromise.then((body) ->
      expect(body.user.username).to.equal username
    ).fail () ->
      throw new Error("Cannot Log in")

  it 'can see latest notifications', ->
    discourse.notifications().fail (body) ->
      throw new Error("Cannot see latest notifications")

  it 'can send a pm', ->
    title = faker.lorem.sentences(1)
    message = faker.lorem.sentences(5)

    discourse.pm({title: title, message: message, target_usernames: testuser }).fail (body) ->
      throw new Error("Cannot send a pm")

  it 'can create a topic', ->
    title = faker.lorem.sentences(1)
    message = faker.lorem.sentences(5)
    discourse.createTopic({
      title
      message
      category: 3
    }).fail (body) ->
      throw new Error("cannot create topic")



