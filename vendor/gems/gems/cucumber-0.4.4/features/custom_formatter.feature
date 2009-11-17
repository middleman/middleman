Feature: Custom Formatter

  Scenario: count tags
    When I run cucumber --format Cucumber::Formatter::TagCloud features
    Then it should fail with
      """
      | @after_file | @background_tagged_before_on_outline | @four | @lots | @one | @sample_four | @sample_one | @sample_three | @sample_two | @three | @two |
      | 1           | 1                                    | 1     | 1     | 1    | 2            | 1           | 2             | 1           | 2      | 1    |

      """

    Scenario: my own formatter
      Given a standard Cucumber project directory structure
      And a file named "features/f.feature" with:
        """
        Feature: i'll use my own
          Scenario: just print me
            Given this step works
        """
      And a file named "features/step_definitions/steps.rb" with:
        """
        Given /^this step works$/ do
        end
        """
      And a file named "features/support/ze/formator.rb" with:
        """
        module Ze
          class Formator
            def initialize(step_mother, io, options)
              @step_mother = step_mother
              @io = io
            end

            def scenario_name(keyword, name, file_colon_line, source_indent)
              @io.puts "$ #{name.upcase}"
            end
          end
        end
        """
      When I run cucumber features/f.feature --format Ze::Formator
      Then STDERR should be empty
      Then it should pass with
        """
        $ JUST PRINT ME

        """
