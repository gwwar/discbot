{expect} = require 'chai'
color = require '../../src/scripts/color'
TestRobot = require '../test_robot'

describe 'scripts/color', ->

  {robot} = {}

  before ->
  # our friendly test robot
    robot = new TestRobot()
    # register our dice script with the test robot
    color(robot)

  it 'can generate a random color', ->
  # simulate a user responding to the bot
    promise = robot.test message: "color"

    promise.then (message) ->
      expect(message).to.match /@defaultname, what about the color: `#[A-F0-9]{6}`/

  it 'has a favorite color', ->
  # simulate a user responding to the bot
    promise = robot.test message: "favorite color"

    promise.then (message) ->
      expect(message).to.equal 'My favorite color is chucknorris'
