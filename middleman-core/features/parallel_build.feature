Feature: Parallel
  In order to speed up large builds we should build in parallel

  Scenario: Build an app
    Given a successfully built app at "large-build-app" with flags "--parallel"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | static.html                                   |
      | services/index.html                           |
      | stylesheets/static.css                        |
      | spaces in file.html                           |
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
    And the file "spaces in file.html" should contain "spaces"

    Scenario: Build and Clean an app ( in parallel )
      Given a fixture app "clean-app"
      And app "clean-app" is using config "empty"
      And a successfully built app at "clean-app" with flags "--parallel"
      Then the following files should exist:
        | build/index.html              |
        | build/should_be_ignored.html  |
        | build/should_be_ignored2.html |
        | build/should_be_ignored3.html |
      And app "clean-app" is using config "complications"
      Given a successfully built app at "clean-app" with flags "--clean --parallel"
      Then the following files should not exist:
        | build/should_be_ignored.html  |
        | build/should_be_ignored2.html |
        | build/should_be_ignored3.html |
      And the file "build/index.html" should contain "Comment in layout"

    Scenario: Clean build an app with newly ignored files and a nested output directory
      Given a built app at "clean-nested-app" with flags "--parallel"
      Then a directory named "sub/dir" should exist
      Then the following files should exist:
        | sub/dir/about.html        |
      When I append to "config.rb" with "ignore 'about.html'"
      Given a built app at "clean-nested-app" with flags "--clean --parallel"
      Then the following files should not exist:
        | sub/dir/about.html        |
        