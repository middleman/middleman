Feature: Map special characters to automatically put files in a directory
  
  Scenario: Building files with special character escape
    Given a successfully built app at "automatic-directory-matcher-app"
    When I cd to "build"
    Then the following files should exist:
      | root.html                                    |
      | root-plain.html                              |
      | sub/sub.html                                 |
      | sub/sub-plain.html                           |
      | sub/sub/sub.html                             |
      | sub/sub/sub-plain.html                       |
    Then the following files should not exist:  
      | sub--sub.html                                 |
      | sub--sub-plain.html                           |
      | sub--sub--sub.html                            |
      | sub--sub--sub-plain.html                      |

  Scenario: Previewing files with special character escape
    Given the Server is running at "automatic-directory-matcher-app"
    When I go to "/root.html"
    Then I should see "Root Erb"
    When I go to "/root-plain.html"
    Then I should see "Root Plain"
    When I go to "/sub/sub.html"
    Then I should see "Sub1 Erb"
    When I go to "/sub/sub-plain.html"
    Then I should see "Sub1 Plain"
    When I go to "/sub/sub/sub.html"
    Then I should see "Sub2 Erb"
    When I go to "/sub/sub/sub-plain.html"
    Then I should see "Sub2 Plain"