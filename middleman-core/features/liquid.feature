Feature: Support liquid partials

  Scenario: Rendering liquid
    Given the Server is running at "liquid-app"
    When I go to "/liquid_master.html"
    Then I should see "Greetings"

  Scenario: Rendering liquid
    Given the Server is running at "liquid-app"
    When I go to "/data2.html"
    Then I should see "OneTwo"

  Scenario: Liquid partial from another folder
     Given the Server is running at "liquid-app"
     When I go to "/include-from-folder.html"
     Then I should see "Include from folder"

  Scenario: Building liquid
    Given a successfully built app at "liquid-app"
