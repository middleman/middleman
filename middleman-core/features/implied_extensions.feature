Feature: Use default extensions when user doesn't supply them

  Scenario: Default extensions preview
    Given the Server is running at "implied-extensions-app"
    When I go to "/"
    Then I should see "hello: world"
    When I go to "/index.html"
    Then I should see "hello: world"
    When I go to "/index.erb"
    Then I should see "File Not Found"
    When I go to "/index"
    Then I should see "File Not Found"
    
  Scenario: Override erb extension
    Given a fixture app "implied-extensions-app"
    And a file named "config.rb" with:
       """
       template_extensions :erb => :htm
       """
    And the Server is running
    When I go to "/"
    Then I should see "File Not Found"
    When I go to "/index.htm"
    Then I should see "hello: world"
    When I go to "/index.erb"
    Then I should see "File Not Found"
    When I go to "/index"
    Then I should see "File Not Found"
    When I go to "/index.html"
    Then I should see "File Not Found"
    
  Scenario: Override erb extension
    Given a fixture app "implied-extensions-app"
    And a file named "config.rb" with:
       """
       set :index_file, "index.htm"
       template_extensions :erb => :htm
       """
    And the Server is running
    When I go to "/"
    Then I should see "hello: world"
    When I go to "/index.htm"
    Then I should see "hello: world"
  
  Scenario: Default extensions build
    Given a fixture app "implied-extensions-app"
    And a successfully built app at "implied-extensions-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html  |
    Then the following files should not exist:
      | index       |
      | index.erb   |
    And the file "index.html" should contain "hello: world"
  
  Scenario: Default extensions build with override
    Given a fixture app "implied-extensions-app"
    And a file named "config.rb" with:
      """
      template_extensions :erb => :htm
      """
    And a successfully built app at "implied-extensions-app"
    When I cd to "build"
    Then the following files should exist:
      | index.htm   |
    Then the following files should not exist:
      | index       |
      | index.erb   |
      | index.html  |