Feature: Getting options from environment variable
  In order to avoid having to type --rspec over and over
  A user will need to set up a JEWELER_OPTS environment variable

  Scenario: Environment variable set
    Given a working directory
    And I set JEWELER_OPTS env variable to "--rspec"
    When I generate a project named 'the-perfect-gem' that is 'zomg, so good'
    Then 'spec/the-perfect-gem_spec.rb' should describe 'ThePerfectGem'
