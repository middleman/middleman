Feature: Directory Index
  In order output Apache-friendly directories and indexes

  Scenario: Checking built folder for content
    Given a successfully built app at "indexable-app"
    When I cd to "build"
    Then the following files should exist:
      | needs_index/index.html                        |
      | a_folder/needs_index/index.html               |
      | leave_me_alone.html                           |
      | wildcard_leave_me_alone.html                  |
      | regular/index.html                            |
      | .htaccess                                     |
    Then the following files should not exist:
      | egular/index/index.html                       |
      | needs_index.html                              |
      | a_folder/needs_index.html                     |
      | leave_me_alone/index.html                     |
      | wildcard_leave_me_alone/index.html            |
    And the file "needs_index/index.html" should contain "Indexable"
    And the file "a_folder/needs_index/index.html" should contain "Indexable"
    And the file "leave_me_alone.html" should contain "Stay away"
    And the file "regular/index.html" should contain "Regular"
    
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