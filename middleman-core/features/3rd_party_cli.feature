Feature: Allow config.rb and extensions to add CLI commands

  Scenario: Command autoloaded from tasks/ directory
    Given an empty app
    And a file named "tasks/hello_task.rb" with:
      """
      class Hello < Thor
        desc "hello", "Say hello"
        def hello
          puts "Hello World"
        end
      end
      """
    When I run `middleman hello`
    Then the output should contain "Hello World"