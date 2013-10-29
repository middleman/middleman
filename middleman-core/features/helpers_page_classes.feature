Feature: Built-in page_classes view helper
  In order to generate body classes for views
  
  Scenario: Viewing the root path
    Given the Server is running at "page-classes-app"
    When I go to "/page-classes.html"
    Then I should see "page-classes"

  Scenario: Viewing a tier-1 path
    Given the Server is running at "page-classes-app"
    When I go to "/sub1/page-classes.html"
    Then I should see "sub1 sub1_page-classes"

  Scenario: Viewing a tier-2 path
    Given the Server is running at "page-classes-app"
    When I go to "/sub1/sub2/page-classes.html"
    Then I should see "sub1 sub1_sub2 sub1_sub2_page-classes"

  Scenario: The page starts with a number
    Given the Server is running at "page-classes-app"
    When I go to "/1-starts-with-numeric.html"
    Then I should see "x1-starts-with-numeric"

  Scenario: The folder starts with a number
    Given the Server is running at "page-classes-app"
    When I go to "/1-folder/1-inside-with-numeric.html"
    Then I should see "x1-folder x1-folder_1-inside-with-numeric"

  Scenario: Custom prefix for numeric
    Given the Server is running at "page-classes-app"
    When I go to "/2-starts-with-numeric-custom.html"
    Then I should see "haaaaay2-starts-with-numeric-custom"