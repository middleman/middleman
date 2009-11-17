Feature: generated test or spec
  In order to start a new gem
  A user should be able to
  generate a test or spec

  Scenario: bacon
    Given a working directory
    And I have configured git sanely
    When I generate a bacon project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'spec/spec_helper.rb' requires 'bacon'
    And 'spec/spec_helper.rb' requires 'the-perfect-gem'

  Scenario: minitest
    Given a working directory
    And I have configured git sanely
    When I generate a minitest project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'test/helper.rb' requires 'minitest/unit'
    And 'test/helper.rb' requires 'the-perfect-gem'
    And 'test/helper.rb' should autorun tests

  Scenario: rspec
    Given a working directory
    And I have configured git sanely
    When I generate a rspec project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'spec/spec_helper.rb' requires 'spec'
    And 'spec/spec_helper.rb' requires 'the-perfect-gem'

  Scenario: shoulda
    Given a working directory
    And I have configured git sanely
    When I generate a shoulda project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'test/helper.rb' requires 'test/unit'
    And 'test/helper.rb' requires 'shoulda'
    And 'test/helper.rb' requires 'the-perfect-gem'

  Scenario: testunit
    Given a working directory
    And I have configured git sanely
    When I generate a testunit project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'test/helper.rb' requires 'test/unit'
    And 'test/helper.rb' requires 'the-perfect-gem'

  Scenario: micronaut
    Given a working directory
    And I have configured git sanely
    When I generate a micronaut project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'examples/example_helper.rb' requires 'rubygems'
    Then 'examples/example_helper.rb' requires 'micronaut'
    Then 'examples/example_helper.rb' requires 'the-perfect-gem'

  Scenario: riot
    Given a working directory
      And I have configured git sanely
    When I generate a riot project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'test/teststrap.rb' requires 'riot'
      And 'test/teststrap.rb' requires 'the-perfect-gem'
