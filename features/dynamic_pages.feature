Feature: Dynamic Pages
  In order to use a single view to generate multiple output files

  Scenario: Checking built folder for content
    Given a built app at "test-app"
    Then a directory named "build" should exist
    
    When I cd to "build"
    Then the following files should exist:
      | fake.html                                     |
      | fake/one.html                                 |
      | fake/two.html                                 |
      | target_ignore.html                            |
    Then the following files should not exist:
      | should_be_ignored.html                        |
      | should_be_ignored2.html                       |
      | should_be_ignored3.html                       |
    
  Scenario: Preview basic proxy
    Given the Server is running at "test-app"
    When I go to "/fake.html"
    Then I should see "I am real"
    
  Scenario: Preview proxy with variable one
    Given the Server is running at "test-app"
    When I go to "/fake/one.html"
    Then I should see "I am real: one"
    
  Scenario: Preview proxy with variable two
    Given the Server is running at "test-app"
    When I go to "/fake/two.html"
    Then I should see "I am real: two"
    
  Scenario: Preview ignored paths
    Given the Server is running at "test-app"  
    When I go to "/should_be_ignored.html"
    Then I should see "File Not Found"