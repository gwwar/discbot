expect = require('chai').expect
help = require '../../src/scripts/help'
TestRobot = require '../test_robot'

describe 'scripts/help', ->

  {robot} = {}

  before ->
    # our friendly test robot
    robot = new TestRobot()
    # register our dice script with the test robot
    help(robot)

  it 'gives some helpful information', ->
    # simulate a user responding to the bot
    promise = robot.test message: "help"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname, I understand:/
