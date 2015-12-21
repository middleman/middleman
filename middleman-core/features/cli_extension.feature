Feature: Middleman New Extension CLI

  Scenario: Create a new extension scaffold
    Given I run `middleman extension my-extension-library`
    Then the exit status should be 0
    When I cd to "my-extension-library"
    Then the following files should exist:
      | Gemfile                                       |
      | Rakefile                                      |
      | my-extension-library.gemspec                  |
      | features/support/env.rb                       |
      | lib/my-extension-library/extension.rb         |
      | lib/my-extension-library.rb                   |
      | .gitignore                                    |
