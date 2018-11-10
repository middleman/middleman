Feature: Generic block based pages

  Scenario: Static Ruby Endpoints
    Given an empty app
    And a file named "config.rb" with:
    """
    endpoint "hello.html" do
      "world"
    end
    """
    And a file named "source/index.html.erb" with:
    """
    Hi
    """
    And the Server is running at "empty_app"
    When I go to "/hello.html"
    Then I should see "world"
