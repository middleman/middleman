Feature: generated directory layout
  In order to start a new gem
  A user should be able to
  generate a directory layout

  Scenario: shared
    Given a working directory
    And I have configured git sanely
    When I generate a project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem' is created
    And a directory named 'the-perfect-gem/lib' is created

    And a file named 'the-perfect-gem/README.rdoc' is created
    And a file named 'the-perfect-gem/.document' is created
    And a file named 'the-perfect-gem/lib/the-perfect-gem.rb' is created

  Scenario: bacon
    Given a working directory
    And I have configured git sanely
    When I generate a bacon project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/spec' is created

    And a file named 'the-perfect-gem/spec/spec_helper.rb' is created
    And a file named 'the-perfect-gem/spec/the-perfect-gem_spec.rb' is created

  Scenario: minitest
    Given a working directory
    And I have configured git sanely
    When I generate a minitest project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/test' is created

    And a file named 'the-perfect-gem/test/helper.rb' is created
    And a file named 'the-perfect-gem/test/test_the-perfect-gem.rb' is created

  Scenario: rspec
    Given a working directory
    And I have configured git sanely
    When I generate a rspec project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/spec' is created

    And a file named 'the-perfect-gem/spec/spec_helper.rb' is created
    And a file named 'the-perfect-gem/spec/the-perfect-gem_spec.rb' is created

  Scenario: shoulda
    Given a working directory
    And I have configured git sanely
    When I generate a shoulda project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/test' is created

    And a file named 'the-perfect-gem/test/helper.rb' is created
    And a file named 'the-perfect-gem/test/test_the-perfect-gem.rb' is created

  Scenario: testunit
    Given a working directory
    And I have configured git sanely
    When I generate a testunit project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/test' is created

    And a file named 'the-perfect-gem/test/helper.rb' is created
    And a file named 'the-perfect-gem/test/test_the-perfect-gem.rb' is created

  Scenario: micronaut
    Given a working directory
    And I have configured git sanely
    When I generate a micronaut project named 'the-perfect-gem' that is 'zomg, so good'

    Then a directory named 'the-perfect-gem/examples' is created

    And a file named 'the-perfect-gem/examples/example_helper.rb' is created
    And a file named 'the-perfect-gem/examples/the-perfect-gem_example.rb' is created
