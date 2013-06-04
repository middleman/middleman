Feature: v4 Extensions should have after_activated hooks

  Scenario: Hello Helper
    Given the Server is running at "v4-extension-callbacks"
    Then going to "/index.html" should not raise an exception
    And I should see "Extension One: true"
    And I should see "Extension Two: true"
    