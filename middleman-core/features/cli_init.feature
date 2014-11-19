Feature: Middleman CLI

  Scenario: Create a new project
    Given I run `middleman init MY_PROJECT`
    Then the exit status should be 0
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | Gemfile                                       |
      | .gitignore                                    |
      | config.rb                                     |
      | source/index.html.erb                         |
      | source/images/background.png                  |
      | source/images/middleman.png                   |
      | source/layouts/layout.erb                     |
      | source/javascripts/all.js                     |
      | source/stylesheets/all.css                    |
      | source/stylesheets/normalize.css              |

  Scenario: Create a new project in the current directory
    Given a directory named "MY_PROJECT"
    When I cd to "MY_PROJECT"
    And I run `middleman init`
    Then the exit status should be 0
    And the following files should exist:
      | Gemfile                                       |
      | config.rb                                     |
      | source/index.html.erb                         |

  Scenario: Create a new project (alias i)
    When I run `middleman i MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias new)
    When I run `middleman new MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias n)
    When I run `middleman n MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist
