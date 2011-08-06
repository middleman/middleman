Feature: Builder
  In order to output static html and css for delivery

  Scenario: Checking built folder for content
    Given a built app at "test-app"
    Then "index.html" should exist at "test-app" and include "Comment in layout"
    Then "javascripts/coffee_test.js" should exist at "test-app" and include "Array.prototype.slice"
    Then "index.html" should exist at "test-app" and include "<h1>Welcome</h1>"
    Then "static.html" should exist at "test-app" and include "Static, no code!"
    Then "services/index.html" should exist at "test-app" and include "Services"
    Then "stylesheets/site.css" should exist at "test-app" and include "html, body, div, span"
    Then "stylesheets/site_scss.css" should exist at "test-app" and include "html, body, div, span"
    Then "stylesheets/static.css" should exist at "test-app" and include "body"
    Then "_partial.html" should not exist at "test-app"
    Then "spaces in file.html" should exist at "test-app" and include "spaces"
    Then "images/Read me (example).txt" should exist at "test-app"
    Then "images/Child folder/regular_file(example).txt" should exist at "test-app"
    And cleanup built app at "test-app"
    
  # Scenario: Force relative assets
  #   Given a built app at "relative-app" with flags "--relative"
  #   Then "stylesheets/relative_assets.css" should exist at "relative-app" and include "../"
  #   And cleanup built app at "relative-app"