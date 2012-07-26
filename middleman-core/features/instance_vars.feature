Feature: Instance Variables
  Scenario: A dynamic page template using instance variables
    Given the Server is running at "instance-vars-app"
    When I go to "/a.html"
    Then I should see "A: 'set'"
    Then I should see "B: ''"
    When I go to "/b.html"
    Then I should see "A: ''"
    Then I should see "B: 'set'"
