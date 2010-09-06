Feature: Built-in page_classes view helper
  In order to generate body classes for views
  
  Scenario: Viewing the root path
    Given the Server is running
    When I go to "/page-class.html"
    Then I should see "page-class"

  Scenario: Viewing a tier-1 path
    Given the Server is running
    When I go to "/sub1/page-class.html"
    Then I should see "sub1 sub1_page-class"

  Scenario: Viewing a tier-2 path
    Given the Server is running
    When I go to "/sub1/sub2/page-class.html"
    Then I should see "sub1 sub1_sub2 sub1_sub2_page-class"