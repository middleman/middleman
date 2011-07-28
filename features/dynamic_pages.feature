Feature: Dynamic Pages
  In order to use a single view to generate multiple output files

  Scenario: Checking built folder for content
    Given a built app at "test-app"
    Then "fake.html" should exist at "test-app" and include "I am real"
    Then "fake/one.html" should exist at "test-app" and include "I am real: one"
    Then "fake/two.html" should exist at "test-app" and include "I am real: two"
    Then "target_ignore.html" should exist at "test-app" and include "Ignore me"
    Then "should_be_ignored.html" should not exist at "test-app"
    Then "should_be_ignored2.html" should not exist at "test-app"
    Then "should_be_ignored3.html" should not exist at "test-app"
    And cleanup built app at "test-app"
    
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