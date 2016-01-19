Feature: Middleman CLI

  Scenario: Create a new project
    When I run `middleman init MY_PROJECT` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
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
    And I run `middleman init` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then the exit status should be 0
    And the following files should exist:
      | Gemfile                                       |
      | config.rb                                     |
      | source/index.html.erb                         |

  Scenario: Create a new project (alias i)
    When I run `middleman i MY_PROJECT` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias new)
    When I run `middleman new MY_PROJECT` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project (alias n)
    When I run `middleman n MY_PROJECT` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project using Middleman directory
    When I run `middleman init MY_PROJECT -T blog`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    And the file "Gemfile" should contain "middleman-blog"
    And the file ".gitignore" should exist

  Scenario: Create an invalid project using Middleman directory
    When I run `middleman init MY_PROJECT -T does-not-exist-for-reals`
    Then the exit status should be 1

  Scenario: Create a new project using github(user/repository)
    When I run `middleman init MY_PROJECT -T middleman/middleman-templates-default` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist

  Scenario: Create a new project using github(user/repository#branch)
    When I run `middleman init MY_PROJECT -T middleman/middleman-templates-default#master` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist
    And the output should contain "-b master"

  Scenario: Create a new project using full path(://)
    When I run `middleman init MY_PROJECT -T https://github.com/middleman/middleman-templates-default.git` interactively
    And I type "y"
    And I type "y"
    And I type "y"
    And I type "y"
    Then a directory named "MY_PROJECT" should exist
