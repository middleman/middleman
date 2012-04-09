Feature: Minify CSS
  In order reduce bytes sent to client and appease YSlow
    
  Background:
    Given current environment is "build"

  Scenario: Rendering external css with the feature disabled
    Given "minify_css" feature is "disabled"
    And the Server is running at "minify-css-app"
    When I go to "/stylesheets/site.css"
    Then I should see "60" lines
    And I should see "only screen and (device-width"
    
  Scenario: Rendering external css with the feature enabled
    Given "minify_css" feature is "enabled"
    And the Server is running at "minify-css-app"
    When I go to "/stylesheets/site.css"
    Then I should see "1" lines
    And I should see "only screen and (device-width"
    When I go to "/more-css/site.css"
    Then I should see "1" lines    
    
  Scenario: Rendering external css with passthrough compressor
    Given the Server is running at "passthrough-app"
    When I go to "/stylesheets/site.css"
    Then I should see "55" lines

  Scenario: Rendering inline css with the feature disabled
    Given "minify_css" feature is "disabled"
    And the Server is running at "minify-css-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style type='text/css'>
      /*<![CDATA[*/
        body {
          test: style;
          good: deal;
        }
      /*]]>*/
    </style>
    """
   
  Scenario: Rendering inline css with a passthrough minifier
    Given the Server is running at "passthrough-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style type='text/css'>
      body {
        test: style;
        good: deal; }
    </style>
    """

  Scenario: Rendering inline css with the feature enabled
    Given "minify_css" feature is "enabled"
    And the Server is running at "minify-css-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style type='text/css'>
      /*<![CDATA[*/
     body{test:style;good:deal}
      /*]]>*/
    </style>
    """