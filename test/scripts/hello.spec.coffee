expect = require('chai').expect
hello = require '../../src/scripts/hello'
TestRobot = require '../test_robot'

describe 'scripts/dice', ->

  {robot} = {}

  before ->
    # our friendly test robot
    robot = new TestRobot()
    # register our dice script with the test robot
    hello(robot)

  it 'responds to the user with a witty message', ->
    # simulate a user responding to the bot
    promise = robot.test message: "hello"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname/
