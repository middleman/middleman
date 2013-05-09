Feature: Lorem generating helper

  Scenario: Lorem Helper
    Given the Server is running at "lorem-app"
    Then going to "/lorem.html" should not raise an exception
    And I should see "http://placekitten.com/100"