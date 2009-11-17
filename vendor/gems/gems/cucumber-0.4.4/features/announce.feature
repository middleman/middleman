Feature: Delayed announcement

    Background:
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
    """
    Given /^I use announce with text "(.*)"$/ do |ann|
        announce(ann)
    end

    Given /^I use multiple announces$/ do
        announce("Multiple")
        announce("Announce")
    end

    Given /^I use announcement (.+) in line (.+) (?:with result (.+))$/ do |ann, line, result|
        announce("Last announcement") if line == "3"
        announce("Line: #{line}: #{ann}")
        fail if result =~ /fail/i
    end

    Given /^I use announce and step fails$/ do
        announce("Announce with fail")
        fail
    end

    Given /^this step works$/ do
    end
    """
    And a file named "features/f.feature" with:
    """
    Scenario: S
    Given I use announce with text "Ann"
    And this step works

    Scenario: S2
    Given I use multiple announces
    And this step works

    Scenario Outline: S3
    Given I use announcement <ann> in line <line>

    Examples:
    | line | ann |
    | 1 | anno1 |
    | 2 | anno2 |
    | 3 | anno3 |

    Scenario: S4
    Given I use announce and step fails
    And this step works

    Scenario Outline: s5
    Given I use announcement <ann> in line <line> with result <result>

    Examples:
    | line | ann | result |
    | 1 | anno1 | fail |
    | 2 | anno2 | pass |
    """

    Scenario: Delayed announcements feature
    When I run cucumber --format pretty features/f.feature
    Then the output should contain
    """
      Scenario: S                            # features/f.feature:1
        Given I use announce with text "Ann" # features/step_definitions/steps.rb:1
          Ann
        And this step works                  # features/step_definitions/steps.rb:21

      Scenario: S2                     # features/f.feature:5
        Given I use multiple announces # features/step_definitions/steps.rb:5
          Multiple
          Announce
        And this step works            # features/step_definitions/steps.rb:21

      Scenario Outline: S3                            # features/f.feature:9
        Given I use announcement <ann> in line <line> # features/f.feature:10

        Examples: 
          | line | ann   |
          | 1    | anno1 |
          | 2    | anno2 |
          | 3    | anno3 |

      Scenario: S4                          # features/f.feature:18
        Given I use announce and step fails # features/step_definitions/steps.rb:16
          Announce with fail
           (RuntimeError)
          ./features/step_definitions/steps.rb:18:in `/^I use announce and step fails$/'
          features/f.feature:19:in `Given I use announce and step fails'
        And this step works                 # features/step_definitions/steps.rb:21

      Scenario Outline: s5                                                 # features/f.feature:22
        Given I use announcement <ann> in line <line> with result <result> # features/step_definitions/steps.rb:10

        Examples: 
          | line | ann   | result |
          | 1    | anno1 | fail   |  Line: 1: anno1
           (RuntimeError)
          ./features/step_definitions/steps.rb:13:in `/^I use announcement (.+) in line (.+) (?:with result (.+))$/'
          features/f.feature:23:in `Given I use announcement <ann> in line <line> with result <result>'
          | 2    | anno2 | pass   |  Line: 2: anno2
"""

    Scenario: Non-delayed announcements feature (progress formatter)
      When I run cucumber --format progress features/f.feature
      Then the output should contain
    """
Ann
..
Multiple

Announce
..-UUUUUU
Announce with fail
F--
Line: 1: anno1
FFF
Line: 2: anno2
...
"""