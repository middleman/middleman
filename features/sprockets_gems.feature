@wip
Feature: Sprockets Gems

  Scenario: Sprockets can pull jQuery from gem
    Given the Server is running at "test-app"
    When I go to "/javascripts/jquery_base.js"
    # Then I should see "sprockets_sub_function"