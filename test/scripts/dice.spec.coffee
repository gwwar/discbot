expect = require('chai').expect
dice = require '../../src/scripts/dice'
TestRobot = require '../test_robot'

describe 'scripts/dice', ->

  {robot} = {}

  before ->
    # our friendly test robot
    robot = new TestRobot()
    # register our dice script with the test robot
    dice(robot)

  it 'can roll a single dice with one side', ->
    # simulate a user responding to the bot
    promise = robot.test message: "roll d1"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.equal "@defaultname the d1 dice reads: 1"

  it 'can roll a single dice with multiple sides', ->
    # simulate a user responding to the bot
    promise = robot.test message: "roll d20"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname the d20 dice reads: \d+/

  it 'can roll multiple dice', ->
      # simulate a user responding to the bot
    promise = robot.test message: "roll 2d20"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname the 2d20 dice reads: \d+ \(\d+,\d+\)/

  it 'can roll multiple dice with positive modifier', ->
    # simulate a user responding to the bot
    promise = robot.test message: "roll 2d20+5"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname the 2d20\+5 dice reads: \d+ \(\d+,\d+\)/

  it 'can roll multiple dice with negative modifier', ->
      # simulate a user responding to the bot
    promise = robot.test message: "roll 2d20-5"

    promise.fail (error) ->
      throw new Error(error)
    promise.then (message) ->
      expect(message).to.match /@defaultname the 2d20-5 dice reads: -?\d+ \(\d+,\d+\)/

  it 'refuses to roll 10 dice', ->
      # simulate a user responding to the bot
    promise = robot.test message: "roll 10d20"

    promise.fail (error) ->
      expect(error.message).to.equal 'No match found!'



