Feature: Automatically detect and insert image dimensions into tags
  In order to speed up development and appease YSlow

  Scenario: Rendering an image with the feature disabled
    Given a fixture app "automatic-image-size-app"
    And a file named "config.rb" with:
      """
      """
    And the Server is running at "automatic-image-size-app"
    When I go to "/auto-image-sizes.html"
    Then I should not see "width="
    And I should not see "height="
    When I go to "/markdown-sizes.html"
    Then I should not see "width="
    And I should not see "height="

  Scenario: Rendering an image with the feature enabled
    Given a fixture app "automatic-image-size-app"
    And a file named "config.rb" with:
      """
      activate :automatic_image_sizes
      """
    And the Server is running at "automatic-image-size-app"
    When I go to "/auto-image-sizes.html"
    Then I should see 'width="1"'
    And I should see 'height="1"'
    When I go to "/markdown-sizes.html"
    Then I should see 'width="1"'
    And I should see 'height="1"'
