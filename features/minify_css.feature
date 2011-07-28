Feature: Minify CSS
  In order reduce bytes sent to client and appease YSlow
    
  # Scenario: Rendering inline css with the feature disabled
  #   Given "minify_css" feature is "disabled"
  #   When I go to "/inline-css.html"
  #   Then I should see "4" lines
    
  Scenario: Rendering external css with the feature disabled
    Given "minify_css" feature is "disabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/site.css"
    Then I should see "55" lines

  # Scenario: Rendering inline css with the feature enabled
  #   Given "minify_css" feature is "enabled"
  #   When I go to "/inline-css.html"
  #   Then I should see "1" lines
    
  Scenario: Rendering external css with the feature enabled
    Given "minify_css" feature is "enabled"
    And the Server is running at "test-app"
    When I go to "/stylesheets/site.css"
    Then I should see "1" lines