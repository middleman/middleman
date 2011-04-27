Feature: Builder
  In order to output static html and css for delivery

  Scenario: Checking built folder for content
    Given a built test app
    Then "index.html" should exist and include "Comment in layout"
    Then "javascripts/coffee_test.js" should exist and include "Array.prototype.slice"
    Then "index.html" should exist and include "<h1>Welcome</h1>"
    Then "static.html" should exist and include "Static, no code!"
    Then "services/index.html" should exist and include "Services"
    Then "stylesheets/site.css" should exist and include "html, body, div, span"
    Then "stylesheets/site_scss.css" should exist and include "html, body, div, span"
    Then "stylesheets/static.css" should exist and include "body"
    Then "_partial.html" should not exist
    And cleanup built test app
    
  Scenario: Force relative assets
    Given a built test app with flags "--relative"
    Then "stylesheets/site.css" should exist and include "../"
    And cleanup built test app