Feature: Middleman CLI

  Scenario: Create a new project
    Given I run `middleman init --default MY_PROJECT`
    Then the exit status should be 0
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | Gemfile                                       |
      | .gitignore                                    |
      | config.rb                                     |
      | source/index.html.erb                         |
      | source/layouts/layout.erb                     |
      | source/javascripts/all.js                     |
      | source/stylesheets/site.css.scss              |
      | source/stylesheets/_normalize.scss            |

  Scenario: Create a new project in the current directory
    Given a directory named "MY_PROJECT"
    When I cd to "MY_PROJECT"
    And I run `middleman init --default`
    Then the exit status should be 0
    And the following files should exist:
      | Gemfile                                       |
      | config.rb                                     |
      | source/index.html.erb                         |

  Scenario: Create a new project (alias i)
    When I run `middleman i --default MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias new)
    When I run `middleman new --default MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias n)
    When I run `middleman n --default MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist
