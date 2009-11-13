@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  #
  # Cucumber's wire protocol is an implementation of Cucumber's internal 'programming language' abstraction,
  # and allows step definitions to be implemented and invoked on any platform.
  #
  # Communication is over a TCP socket, which Cucumber connects to when it finds a definition file with the
  # .wire extension in the step_definitions folder (or other load path).
  #
  # There are currently two messages which Cucumber sends over the wire:
  #
  #   * step_matches : this is used to find out whether the wire end has a definition for a given step
  #   * invoke       : this is used to ask for a step definition to be invoked
  #
  # Message packets are formatted as JSON-encoded strings, with a newline character signalling the end of a
  # packet. These messages are described below, with examples.
  #

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
        Scenario: Wired
          Given we're all wired

      """
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 54321

      """


  #
  # step_matches
  #
  # When the features have been parsed, Cucumber will send a step_matches message to ask the wire end
  # if it can match a step name. This happens for each of the steps in each of the features.
  # The wire end replies with a step_match array, containing the IDs of any step definitions that could
  # be invoked for the given step name.

  Scenario: Dry run finds no step match
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["step_matches",[]] |
    When I run cucumber --dry-run -f progress features
    And it should pass with
      """
      U

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  # When a step match is returned, it contains an identifier for the step definition to be used
  # later when referring to this step definition again if it needs to be invoked. The identifier
  # can take any form (as long as it's within a string) and is simply used for the wire end's own
  # reference.
  # The step match also contains any argument values as parsed out by the wire end's own regular
  # expression or other argument matching process.
  Scenario: Dry run finds a step match
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                 |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["step_matches",[{"id":"1", "args":[]}]] |
    When I run cucumber --dry-run -f progress features
    And it should pass with
      """
      -

      1 scenario (1 skipped)
      1 step (1 skipped)

      """


  #
  # invoke
  #
  # Assuming a step_match was returned for a given step name, when it's time to invoke that
  # step definition, Cucumber will send an invoke message.
  # The message contains the ID of the step definition, as returned by the wire end from the
  # step_matches call, along with the arguments that were parsed from the step name during the
  # same step_matches call.
  # The wire end will reply with either a step_failed or a success message.

  Scenario: Invoke a step definition which passes
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                 |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["step_matches",[{"id":"1", "args":[]}]] |
      | ["begin_scenario",null]                              | ["success",null]                         |
      | ["invoke",{"id":"1","args":[]}]                      | ["success",null]                         |
      | ["end_scenario",null]                                | ["success",null]                         |
    When I run cucumber -f progress --backtrace features
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """

  # When a step definition fails, it can return details of the exception in the reply to invoke. These
  # will then be passed by Cucumber to the formatters for display to the user.
  #
  Scenario: Invoke a step definition which fails
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                         |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["step_matches",[{"id":"1", "args":[]}]]         |
      | ["begin_scenario",null]                              | ["success",null]                                 |
      | ["invoke",{"id":"1","args":[]}]                      | ["step_failed",{"message":"The wires are down"}] |
      | ["end_scenario",null]                                | ["success",null]                                 |
    When I run cucumber -f progress features
    Then STDERR should be empty
    And it should fail with
      """
      F

      (::) failed steps (::)

      The wires are down (Cucumber::WireSupport::WireException)
      features/wired.feature:2:in `Given we're all wired'

      Failing Scenarios:
      cucumber features/wired.feature:1 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)

      """

  # Imagine we have a step definition like:
  #
  #     Given /we're all (.*)/ do |what_we_are|
  #     end
  #
  # When this step definition matches the step name in our feature, the word 'wired' will be parsed as an
  # argument.
  #
  # Cucumber expects this StepArgument to be returned in the StepMatch. The keys have the following meanings:
  #   * val : the value of the string captured for that argument from the step name passed in step_matches
  #   * pos : the position within the step name that the argument was matched (used for formatter highlighting)
  #
  Scenario: Invoke a step definition which takes arguments (and passes)
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                                                          |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["step_matches",[{"id":"1", "args":[{"val":"wired", "pos":10}]}]] |
      | ["begin_scenario",null]                              | ["success",null]                                                  |
      | ["invoke",{"id":"1","args":["wired"]}]               | ["success",null]                                                  |
      | ["end_scenario",null]                                | ["success",null]                                                  |
    When I run cucumber -f progress --backtrace features
    Then STDERR should be empty
    And it should pass with
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """


  Scenario: Unexpected response
    Given there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response   |
      | ["begin_scenario",null]                              | ["yikes"]  |
    When I run cucumber -f progress features
    Then STDERR should match
      """
      undefined method `handle_yikes'
      """
