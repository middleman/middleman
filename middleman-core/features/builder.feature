Feature: Builder
  In order to output static html and css for delivery

  Scenario: Checking built folder for content
    Given a successfully built app at "large-build-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | static.html                                   |
      | services/index.html                           |
      | stylesheets/static.css                        |
      | images/blank.gif                              |
      | images/Read me (example).txt                  |
      | images/Child folder/regular_file(example).txt |
      | .htaccess                                     |
      | .htpasswd                                     |
      | feed.xml                                      |
    Then the following files should not exist:
      | _partial                                      |
      | layout                                        |
      | layouts/custom                                |
      | layouts/content_for                           |

    And the file "index.html" should contain "Comment in layout"
    And the file "index.html" should contain "<h1>Welcome</h1>"
    And the file "static.html" should contain "Static, no code!"
    And the file "services/index.html" should contain "Services"
    And the file "stylesheets/static.css" should contain "body"

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

  Scenario: Build external_pipeline errors
    Given a built app at "external-pipeline-error"
    Then the exit status should be 1

  Scenario: Build alias (b)
    Given a fixture app "large-build-app"
    When I run `middleman b`
    Then was successfully built

  Scenario: Builded text file(ex: html, css, xml, txt)'s permission is 0644
    Given a successfully built app at "large-build-app"
    When I cd to "build"
    Then the mode of filesystem object "index.html" should match "0644"
    And the mode of filesystem object "stylesheets/static.css" should match "0644"
    And the mode of filesystem object "feed.xml" should match "0644"
    And the mode of filesystem object ".htaccess" should match "0644"
