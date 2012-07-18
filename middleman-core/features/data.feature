Feature: Local Data API
  In order to abstract content from structure

  Scenario: Rendering html
    Given the Server is running at "basic-data-app"
    When I go to "/data.html"
    Then I should see "One:Two"
  
  Scenario: Rendering json
    Given the Server is running at "basic-data-app"
    When I go to "/data3.html"
    Then I should see "One:Two"
    
  Scenario: Using data in config.rb
    Given the Server is running at "data-app"
    When I go to "/test1.html"
    Then I should see "Welcome"
    
  Scenario: Using data2 in config.rb
    Given the Server is running at "data-app"
    When I go to "/test2.html"
    Then I should see "Welcome"
    
  Scenario: Using data in sass
    Given the Server is running at "data-app"
    When I go to "/stylesheets/theme.css"
    Then I should see "background: yellow"
    Then I should see "font-weight: bold"
    Then I should not see "extra:"
    Then I should see "color: rgba(255, 0, 0, 0.5)"