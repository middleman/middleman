Feature: Dynamic Pages
  In order to use a single view to generate multiple output files

  Scenario: Checking built folder for content
    Given a successfully built app at "dynamic-pages-app"
    When I cd to "build"
    Then the following files should exist:
      | fake.html                                     |
      | fake2.html                                    |
      | fake3.html                                    |
      | fake4.html                                    |
      | fake/one.html                                 |
      | fake/two.html                                 |
      | fake2/one.html                                |
      | fake2/two.html                                |
      | fake3/one.html                                |
      | fake3/two.html                                |
      | fake4/one.html                                |
      | fake4/two.html                                |
      | target_ignore.html                            |
      | target_ignore2.html                           |
      | target_ignore3.html                           |
      | target_ignore4.html                           |
      | 明日がある.html                               |
    Then the following files should not exist:
      | should_be_ignored.html                        |
      | should_be_ignored2.html                       |
      | should_be_ignored3.html                       |
      | should_be_ignored4.html                       |
      | should_be_ignored5.html                       |
      | should_be_ignored6.html                       |
      | should_be_ignored7.html                       |
      | should_be_ignored8.html                       |
    
  Scenario: Preview basic proxy
    Given the Server is running at "dynamic-pages-app"
    When I go to "/fake.html"
    Then I should see "I am real"
    When I go to "/fake2.html"
    Then I should see "I am real"
    When I go to "/fake3.html"
    Then I should see "I am real"
    When I go to "/fake4.html"
    Then I should see "I am real"
    
  Scenario: Preview proxy with variable one
    Given the Server is running at "dynamic-pages-app"
    When I go to "/fake/one.html"
    Then I should see "I am real: one"
    Then I should see "Global: I am one glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake2/one.html"
    Then I should see "I am real: one"
    Then I should see "Global: I am two glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake3/one.html"
    Then I should see "I am real: one"
    Then I should see "Global: I am three glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake4/one.html"
    Then I should see "I am real: one"
    Then I should see "Global: I am four glob"
    Then I should see "All: I am all glob"
    
  Scenario: Preview proxy with variable two
    Given the Server is running at "dynamic-pages-app"
    When I go to "/fake/two.html"
    Then I should see "I am real: two"
    Then I should see "Global: I am one glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake2/two.html"
    Then I should see "I am real: two"
    Then I should see "Global: I am two glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake3/two.html"
    Then I should see "I am real: two"
    Then I should see "Global: I am three glob"
    Then I should see "All: I am all glob"
    
    When I go to "/fake4/two.html"
    Then I should see "I am real: two"
    Then I should see "Global: I am four glob"
    Then I should see "All: I am all glob"

  Scenario: Build proxy with variable one
    Given a successfully built app at "dynamic-pages-app"
    When I cd to "build"
    Then the file "fake/one.html" should contain "I am real: one"
    Then the file "fake/one.html" should contain "Global: I am one glob"
    Then the file "fake/one.html" should contain "All: I am all glob"

    Then the file "fake2/one.html" should contain "I am real: one"
    Then the file "fake2/one.html" should contain "Global: I am two glob"
    Then the file "fake2/one.html" should contain "All: I am all glob"

    Then the file "fake3/one.html" should contain "I am real: one"
    Then the file "fake3/one.html" should contain "Global: I am three glob"
    Then the file "fake3/one.html" should contain "All: I am all glob"
    
  Scenario: Target ignore
    Given the Server is running at "dynamic-pages-app"
    When I go to "/target_ignore.html"
    Then I should see "Ignore me! 3"
    When I go to "/target_ignore2.html"
    Then I should see "Ignore me! 6"
    When I go to "/target_ignore3.html"
    Then I should see "Ignore me! 7"
    When I go to "/target_ignore4.html"
    Then I should see "Ignore me! 8"
    
  Scenario: Preview ignored paths
    Given the Server is running at "dynamic-pages-app"
    When I go to "/should_be_ignored.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored2.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored3.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored4.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored5.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored6.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored7.html"
    Then I should see "File Not Found"
    When I go to "/should_be_ignored8.html"
    Then I should see "File Not Found"