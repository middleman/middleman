Feature: Ignoring paths
  Scenario: Ignore with directory indexes (source file, build)
    Given a fixture app "more-ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And a successfully built app at "more-ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/about/index.html |
      | build/plain/index.html |
    
  Scenario: Ignore with directory indexes (source file, server)
    Given a fixture app "more-ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And the Server is running
    When I go to "/index.html"
    Then I should not see "File Not Found"
    When I go to "/about/index.html"
    Then I should see "File Not Found"
    When I go to "/plain/index.html"
    Then I should see "File Not Found"
  
  Scenario: Ignore with directory indexes (output path splat, build)
    Given a fixture app "more-ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about*'
      ignore 'plain*'
      """
    And a successfully built app at "more-ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/about/index.html |
      | build/plain/index.html |
    
  Scenario: Ignore with directory indexes (output path splat, server)
    Given a fixture app "more-ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about*'
      ignore 'plain*'
      """
    And the Server is running
    When I go to "/index.html"
    Then I should not see "File Not Found"
    When I go to "/about/index.html"
    Then I should see "File Not Found"
    When I go to "/plain/index.html"
    Then I should see "File Not Found"