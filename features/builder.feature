Feature: Builder
  In order to output static html and css for delivery

  Scenario: Checking built folder for content
    Given a successfully built app at "test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | javascripts/coffee_test.js                    |
      | static.html                                   |
      | services/index.html                           |
      | stylesheets/site.css                          |
      | stylesheets/site_scss.css                     |
      | stylesheets/static.css                        |
      | spaces in file.html                           |
      | images/blank.gif                              |
      | images/Read me (example).txt                  |
      | images/Child folder/regular_file(example).txt |
      | .htaccess                                     |
    Then the following files should not exist:
      | _partial                                      |
      | _liquid_partial                               |
      | layout                                        |
      | other_layout                                  |
      | layouts/custom                                |
      | layouts/content_for                           |
      
    And the file "index.html" should contain "Comment in layout"
    And the file "index.html" should contain "<h1>Welcome</h1>"
    And the file "javascripts/coffee_test.js" should contain "Array.prototype.slice"
    And the file "static.html" should contain "Static, no code!"
    And the file "services/index.html" should contain "Services"
    And the file "stylesheets/site.css" should contain "html, body, div, span"
    And the file "stylesheets/site_scss.css" should contain "html, body, div, span"
    And the file "stylesheets/static.css" should contain "body"
    And the file "spaces in file.html" should contain "spaces"
    
  Scenario: Build glob
    Given a successfully built app at "glob-app" with flags "--glob '*.css'"
    When I cd to "build"
    Then the following files should not exist:
      | index.html                                    |
    Then the following files should exist:
      | stylesheets/site.css                          |
  
  Scenario: Build with errors
    Given a built app at "build-with-errors-app"
    Then the exit status should be 1
  
  Scenario: Build empty errors
    Given a built app at "empty-app"
    Then the exit status should be 1

  Scenario: Build alias (b)
    Given a fixture app "test-app"
    When I run `middleman b`
    Then was successfully built