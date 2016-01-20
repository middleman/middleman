Feature: Import files

  Scenario: Move one path to another
    Given the Server is running at "import-app"
    When I go to "/static.html"
    Then I should see 'Not Found'
    When I go to "/static2.html"
    Then I should see 'Static, no code!'

  Scenario: Import all of bower
    Given the Server is running at "import-app"
    When I go to "/bower_components/jquery/dist/jquery.js"
    Then I should see 'jQuery'
    When I go to "/bower_components2/jquery/dist/jquery.js"
    Then I should see 'jQuery'
