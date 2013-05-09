Feature: Instance Vars
  In order to share data with layouts and partials via instance variables

  Scenario: Setting an instance var in a template should be visible in its layout
    Given the Server is running at "more-instance-vars-app"
    When I go to "/instance-var-set.html"
    Then I should see "Var is 100"

  Scenario: Setting an instance var in a template should be visible in a partial
    Given the Server is running at "more-instance-vars-app"
    When I go to "/instance-var-set.html"
    Then I should see "My var is here!"

  Scenario: Setting an instance var in one file should not be visible in another
    Given the Server is running at "more-instance-vars-app"
    When I go to "/instance-var-set.html"
    When I go to "/no-instance-var.html"
    Then I should see "No var..."
