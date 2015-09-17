Feature: Meta redirects

  Scenario: Redirect to unknown file
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    redirect "hello.html", to: "world.html"
    """
    And the Server is running at "large-build-app"
    When I go to "/hello.html"
    Then I should see '<link rel="canonical" href="world.html"'
    Then I should see '<meta http-equiv=refresh content="0; url=world.html"'

  Scenario: Redirect to external site
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    redirect "hello.html", to: "http://example.com"
    """
    And the Server is running at "large-build-app"
    When I go to "/hello.html"
    Then I should see '<meta http-equiv=refresh content="0; url=http://example.com"'

  Scenario: Redirect to a resource
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    ready do
      r = sitemap.find_resource_by_path("static.html")
      redirect "hello.html", to: r
    end
    """
    And the Server is running at "large-build-app"
    When I go to "/hello.html"
    Then I should see '<meta http-equiv=refresh content="0; url=/static.html"'

  Scenario: Redirect to a path with directory index
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    activate :directory_indexes
    redirect "hello.html", to: "link_test.html"
    redirect "hello2.html", to: "services/index.html"
    """
    And the Server is running at "large-build-app"
    When I go to "/hello/index.html"
    Then I should see '<meta http-equiv=refresh content="0; url=/link_test/"'
    When I go to "/hello2/index.html"
    Then I should see '<meta http-equiv=refresh content="0; url=/services/"'

  Scenario: Redirect with custom html
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
    """
    redirect "hello.html", to: "world.html" do |from, to|
      "#{from} to #{to}"
    end
    """
    And the Server is running at "large-build-app"
    When I go to "/hello.html"
    Then I should see 'hello.html to world.html'