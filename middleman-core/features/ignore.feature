Feature: Ignoring paths
  Scenario: Ignore a single path (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/plain.html |
      | build/about.html |
      
  Scenario: Ignore a single path (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
       """
       ignore 'about.html.erb'
       ignore 'plain.html'
       """
    And the Server is running
    When I go to "/index.html"
    Then I should not see "File Not Found"
    When I go to "/plain.html"
    Then I should see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"

  Scenario: Ignore a globbed path (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore '*.erb'
      ignore 'reports/*'
      ignore 'images/**/*.png'
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/plain.html |
      | build/images/portrait.jpg |
      | build/images/pic.png |
    And the following files should not exist:
      | build/about.html |
      | build/index.html |
      | build/reports/index.html |
      | build/reports/another.html |
      | build/images/icons/messages.png |
      
  Scenario: Ignore a globbed path (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore '*.erb'
      ignore 'reports/*'
      ignore 'images/**/*.png'
      """
    And the Server is running
    When I go to "/plain.html"
    Then I should not see "File Not Found"
    When I go to "/images/portrait.jpg"
    Then I should not see "File Not Found"
    When I go to "/images/pic.png"
    Then I should not see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"
    When I go to "/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/another.html"
    Then I should see "File Not Found"
    When I go to "/images/icons/messages.png"
    Then I should see "File Not Found"

  Scenario: Ignore a regex (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore /^.*\.erb/
      ignore /^reports\/.*/
      ignore /^images\.*\.png/
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/plain.html |
      | build/images/portrait.jpg |
      | build/images/pic.png |
    And the following files should not exist:
      | build/about.html |
      | build/index.html |
      | build/reports/index.html |
      | build/reports/another.html |
      | build/images/icons/messages.png |
      
  Scenario: Ignore a regex (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore /^.*\.erb/
      ignore /^reports\/.*/
      ignore /^images\.*\.png/
      """
    And the Server is running
    When I go to "/plain.html"
    Then I should not see "File Not Found"
    When I go to "/images/portrait.jpg"
    Then I should not see "File Not Found"
    When I go to "/images/pic.png"
    Then I should not see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"
    When I go to "/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/another.html"
    Then I should see "File Not Found"
    When I go to "/images/icons/messages.png"
    Then I should see "File Not Found"