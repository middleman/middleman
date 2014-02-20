Feature: Allow config.rb and extensions to add CLI commands

  Scenario: Command autoloaded from tasks/ directory
    Given an empty app
    And a file named "tasks/hello_task.rb" with:
      """
      module Middleman::Cli
        class Hello < Thor
          namespace :hello

          desc "hello", "Say hello"
          def hello
            puts "Hello World"
          end
        end
      end
      """
    When I run `middleman hello`
    Then the output should contain "Hello World"

  Scenario: Command autoloaded from tasks/ directory added to task list
    Given an empty app
    And a file named "tasks/hello_task.rb" with:
      """
      module Middleman::Cli
        class Hello < Thor
          namespace :hello

          desc "hello", "Say hello"
          def hello
            puts "Hello World"
          end
        end
      end
      """
    When I run `middleman help`
    Then the output should contain "Say hello"
