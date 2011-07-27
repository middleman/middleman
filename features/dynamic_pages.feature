Feature: Dynamic Pages
  In order to use a single view to generate multiple output files

  Scenario: Checking built folder for content
    Given a built test app
    Then "fake.html" should exist and include "I am real"
    Then "fake/one.html" should exist and include "I am real: one"
    Then "fake/two.html" should exist and include "I am real: two"
    Then "target_ignore.html" should exist and include "Ignore me"
    Then "should_be_ignored.html" should not exist
    Then "should_be_ignored2.html" should not exist
    Then "should_be_ignored3.html" should not exist
    And cleanup built test app
    
  Scenario: Preview basic proxy
    Given the Server is running
    When I go to "/fake.html"
    Then I should see "I am real"
    
  Scenario: Preview proxy with variable one
    Given the Server is running
    When I go to "/fake/one.html"
    Then I should see "I am real: one"
    
  Scenario: Preview proxy with variable two
    Given the Server is running
    When I go to "/fake/two.html"
    Then I should see "I am real: two"