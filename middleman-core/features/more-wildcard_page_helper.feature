Feature: Wildcards in Page helper

  Scenario: Setting the layout for a folder
    Given the Server is running at "wildcard-directory-index-app"
    When I go to "/"
    Then I should see "Normal Layout"
    When I go to "/admin/"
    Then I should see "Admin Layout"
    When I go to "/admin/page/"
    Then I should see "Admin Layout"