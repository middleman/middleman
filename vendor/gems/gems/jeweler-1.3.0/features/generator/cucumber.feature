Feature: generating cucumber stories
  In order to get started using cucumber in a project
  A user should be able to
  generate a project setup for their testing framework of choice

  Scenario: sans cucumber setup
    Given a working directory
    And I have configured git sanely
    And I do not want cucumber stories
    When I generate a project named 'the-perfect-gem' that is 'zomg, so good'

    And a file named 'the-perfect-gem/features/the-perfect-gem.feature' is not created
    And a file named 'the-perfect-gem/features/support/env.rb' is not created
    And a file named 'the-perfect-gem/features/steps/the-perfect-gem_steps.rb' is not created

  Scenario: basic cucumber setup
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a project named 'the-perfect-gem' that is 'zomg, so good'

    Then cucumber directories are created

    And a file named 'the-perfect-gem/features/the-perfect-gem.feature' is created
    And a file named 'the-perfect-gem/features/support/env.rb' is created
    And a file named 'the-perfect-gem/features/step_definitions/the-perfect-gem_steps.rb' is created

    And 'features/support/env.rb' requires 'the-perfect-gem'

  Scenario: cucumber setup for bacon
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a bacon project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'test/unit/assertions'
    And cucumber world extends "Test::Unit::Assertions"

  Scenario: cucumber setup for shoulda
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a shoulda project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'test/unit/assertions'
    And cucumber world extends "Test::Unit::Assertions"

  Scenario: cucumber setup for testunit
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a testunit project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'test/unit/assertions'
    And cucumber world extends "Test::Unit::Assertions"

  Scenario: cucumber setup for minitest
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a minitest project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'minitest/unit'
    And cucumber world extends "MiniTest::Assertions"

  Scenario: cucumber setup for rspec
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a rspec project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'the-perfect-gem'
    And 'features/support/env.rb' requires 'spec/expectations'

  Scenario: cucumber setup for mirconaut
    Given a working directory
    And I have configured git sanely
    And I want cucumber stories
    When I generate a micronaut project named 'the-perfect-gem' that is 'zomg, so good'

    Then 'features/support/env.rb' requires 'the-perfect-gem'
    And 'features/support/env.rb' requires 'micronaut/expectations'
    And cucumber world extends "Micronaut::Matchers"
