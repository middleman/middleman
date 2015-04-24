Feature: Support srcset property as params for image_tag helper
  This lets you specify responsive image sizes

  Scenario: Rendering an image with the feature enabled
    Given the Server is running at "image-srcset-paths-app"
    When I go to "/image-srcset-paths.html"
    Then I should see '//example.com/remote-image.jpg 2x, /images/blank_3x.jpg 3x'