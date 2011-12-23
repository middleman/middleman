Feature: Generator

  Scenario: Copying template files
    Given I run `middleman init generator-test`
    Then the exit status should be 0
    When I cd to "generator-test"
    Then the following files should exist:
      | config.rb                                     |
      | source/index.html.erb                         |
      | source/images/background.png                  |
      | source/images/middleman.png                   |
      | source/layouts/layout.erb                     |
      | source/javascripts/all.js                     |
      | source/stylesheets/all.css.scss               |
      | source/stylesheets/_animate.scss              |
      | source/stylesheets/_normalize.scss            |