Feature: http://gist.github.com/221223
  In order to make it easier to extract several steps from
  a feature file to a step definition I want to be able to
  copy and paste.

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: Test

        Scenario: Multiline string
          Given a multiline string:
             \"\"\"
             hello
             world
             \"\"\"

        Scenario: Call a multiline string
          Given I call a multiline string with MAMA

        Scenario: Call a table
          Given I call a table with MAMA
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^a multiline string:$/ do |s|
        raise "I got multiline:\n#{s}"
      end

      Given /^a table:$/ do |t|
        raise "I got table:\n#{t.raw.inspect}"
      end

      Given /^I call a multiline string with (.*)$/ do |s|
        steps %Q{
          Given a multiline string:
            \"\"\"
            hello
            #{s}
            \"\"\"
        }
      end

      Given /^I call a table with (.*)$/ do |s|
        steps %Q{
          Given a table:
            |a|b|
            |c|#{s}|
        }
      end
      """

  Scenario: Multiline string
    When I run cucumber features/f.feature:6
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Test

        Scenario: Multiline string  # features/f.feature:3
          Given a multiline string: # features/step_definitions/steps.rb:1
            \"\"\"
            hello
            world
            \"\"\"
            I got multiline:
            hello
            world (RuntimeError)
            ./features/step_definitions/steps.rb:2:in `/^a multiline string:$/'
            features/f.feature:4:in `Given a multiline string:'

      Failing Scenarios:
      cucumber features/f.feature:3 # Scenario: Multiline string
      
      1 scenario (1 failed)
      1 step (1 failed)

      """

  Scenario: Call multiline string
    When I run cucumber features/f.feature:10
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Test

        Scenario: Call a multiline string           # features/f.feature:10
          Given I call a multiline string with MAMA # features/step_definitions/steps.rb:9
            I got multiline:
            hello
            MAMA (RuntimeError)
            ./features/step_definitions/steps.rb:2:in `/^a multiline string:$/'
            features/f.feature:11:in `Given I call a multiline string with MAMA'

      Failing Scenarios:
      cucumber features/f.feature:10 # Scenario: Call a multiline string

      1 scenario (1 failed)
      1 step (1 failed)

      """

  Scenario: Call table
    When I run cucumber features/f.feature:13
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Test

        Scenario: Call a table           # features/f.feature:13
          Given I call a table with MAMA # features/step_definitions/steps.rb:19
            I got table:
            [["a", "b"], ["c", "MAMA"]] (RuntimeError)
            ./features/step_definitions/steps.rb:6:in `/^a table:$/'
            features/f.feature:14:in `Given I call a table with MAMA'

      Failing Scenarios:
      cucumber features/f.feature:13 # Scenario: Call a table

      1 scenario (1 failed)
      1 step (1 failed)

      """
