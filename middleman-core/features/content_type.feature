Feature: Setting the right content type for files

  Scenario: The right content type gets automatically determined
    Given the Server is running at "content-type-app"
    When I go to "/index.html"
    Then the content type should be "text/html"
    When I go to "/images/blank.gif"
    Then the content type should be "image/gif"
    When I go to "/javascripts/app.js"
    Then the content type should be "application/javascript"
    When I go to "/stylesheets/site.css"
    Then the content type should be "text/css"
    When I go to "/README"
    Then the content type should be "text/plain"
    When I go to "/index.php"
    Then the content type should be "text/php"

  Scenario: Content type can be set explicitly via page or proxy or frontmatter
    Given a fixture app "content-type-app"
    And a file named "config.rb" with:
    """
    page "README", :content_type => 'text/awesome'
    proxy "bar", "index.html", :content_type => 'text/custom'
    proxy "foo", "README" # auto-delegate to target content type
    """
    And the Server is running at "content-type-app"
    When I go to "/README"
    Then the content type should be "text/awesome"
    When I go to "/bar"
    Then the content type should be "text/custom"
    When I go to "/foo"
    Then the content type should be "text/awesome"
    When I go to "/override.html"
    Then the content type should be "text/neato"

  @preserve_mime_types
  Scenario: Content types can be overridden with mime_type
    Given a fixture app "content-type-app"
    And a file named "config.rb" with:
    """
    mime_type('.js', 'application/x-javascript')
    """
    And the Server is running at "content-type-app"
    When I go to "/javascripts/app.js"
    Then the content type should be "application/x-javascript"

