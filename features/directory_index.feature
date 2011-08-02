Feature: Directory Index
  In order output Apache-friendly directories and indexes

  Scenario: Checking built folder for content
    Given a built app at "indexable-app"
    Then "needs_index/index.html" should exist at "indexable-app" and include "Indexable"
    Then "a_folder/needs_index/index.html" should exist at "indexable-app" and include "Indexable"
    Then "leave_me_alone.html" should exist at "indexable-app" and include "Stay away"
    Then "regular/index.html" should exist at "indexable-app" and include "Regular"
    Then "regular/index/index.html" should not exist at "indexable-app"
    Then "needs_index.html" should not exist at "indexable-app"
    Then "a_folder/needs_index.html" should not exist at "indexable-app"
    Then "leave_me_alone/index.html" should not exist at "indexable-app"
    And cleanup built app at "indexable-app"
    
  Scenario: Preview normal file
    Given the Server is running at "indexable-app"
    When I go to "/needs_index/"
    Then I should see "Indexable"
    
  Scenario: Preview normal file subdirectory
    Given the Server is running at "indexable-app"
    When I go to "/a_folder/needs_index/"
    Then I should see "Indexable"
    
  Scenario: Preview ignored file
    Given the Server is running at "indexable-app"
    When I go to "/leave_me_alone/"
    Then I should see "File Not Found"