Feature: Compass sprites should be generated on build and copied
  Scenario: Compass sprites in preview server
    Given the Server is running at "compass-sprites-app"
    When I go to "/stylesheets/site.css"
    Then I should see "/images/icon-s1a8aa64128.png"
    And I should see ".icon-sprite, .icon-arrow_down, .icon-arrow_left, .icon-arrow_right, .icon-arrow_up"
    When I go to "/images/icon-s1a8aa64128.png"
    Then the response code should be "200"
    Then the following files should not exist:
      | source/images/icon-s1a8aa64128.png |

  Scenario: Building a clean site with sprites
    Given a successfully built app at "compass-sprites-app" with flags "--clean"
    Then the following files should not exist:
      | source/images/icon-s1a8aa64128.png |
    When I cd to "build"
    Then the following files should exist:
      | images/icon-s1a8aa64128.png |
    And the file "stylesheets/site.css" should contain "icon-s1a8aa64128.png"
    