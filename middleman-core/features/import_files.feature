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

  Scenario: Import renderable files
    Given the Server is running at "import-app"
    When I go to "/import.html"
    Then I should see '<h1 id="hello">Hello</h1>'
    When I go to "/import_with_frontmatter.html"
    Then I should see '<div>Hello</div>'
    Then I should not see content matching %r{---}

  Scenario: Import renderable paths
    Given the Server is running at "import-app"
    When I go to "/paths/import.html"
    Then I should see '<h1 id="hello">Hello</h1>'
    When I go to "/paths/import_with_frontmatter.html"
    Then I should see '<div>Hello</div>'
    Then I should not see content matching %r{---}
    When I go to "/paths/nested/import.html"
    Then I should see '<h1 id="hello">Hello</h1>'

