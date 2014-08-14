Feature: Automatically detect and insert image dimensions into tags
  In order to speed up development and appease YSlow

  Scenario: Rendering an image with the feature enabled
    Given "automatic_alt_tags" feature is "enabled"
    And the Server is running at "automatic-alt-tags-app"
    When I go to "/auto-image-sizes.html"
    Then I should see 'alt="Blank"'