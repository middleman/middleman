Feature: Automatically detect and insert image dimensions into tags
  In order to speed up development and appease YSlow

  Scenario: Rendering an image with the feature disabled
    Given "automatic_image_sizes" feature is "disabled"
    When I go to "/auto-image-sizes.html"
    Then I should not see "width="
    And I should not see "height="
  
  Scenario: Rendering an image with the feature enabled
    Given "automatic_image_sizes" feature is "enabled"
    When I go to "/auto-image-sizes.html"
    Then I should see "width="
    And I should see "height="