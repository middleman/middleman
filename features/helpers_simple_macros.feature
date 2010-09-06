Feature: Built-in macro view helpers
  In order to simplify generating HTML

  Scenario: Using the link_to helper
    Given the Server is running
    When I go to "/link_to.html"
    Then I should see '<a href="#">No Href</a>'
    And I should see '<a href="test.com">Has Href</a>'
    And I should see '<a class="test" href="test2.com">Has param</a>'

  Scenario: Using the image_tag helper
    Given the Server is running
    When I go to "/image_tag.html"
    Then I should see '<img src="/images/test.png" alt="" />'
    And I should see '<img src="/images/test2.png" alt="alt" />'

  Scenario: Using the javascript_include_tag helper
    Given the Server is running
    When I go to "/javascript_include_tag.html"
    Then I should see '<script type="text/javascript" src="/javascripts/test1.js"></script>'
    Then I should see '<script type="text/javascript" src="/javascripts/test2.js"></script>'
    Then I should see '<script type="text/javascript" src="/javascripts/test3.js"></script>'
    Then I should see '<script type="text/javascript" src="http://test.com/javascripts/test4.js"></script>'
    
  Scenario: Using the stylesheet_link_tag helper
    Given the Server is running
    When I go to "/stylesheet_link_tag.html"
    Then I should see '<link type="text/css" rel="stylesheet" href="/stylesheets/test1.css" />'
    Then I should see '<link type="text/css" rel="stylesheet" href="/stylesheets/test2.css" />'
    Then I should see '<link type="text/css" rel="stylesheet" href="/stylesheets/test3.css" />'
    Then I should see '<link type="text/css" rel="stylesheet" href="http://test.com/stylesheets/test4.css" />'