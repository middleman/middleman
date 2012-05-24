Feature: relative_link_to helper

  Scenario: relative_link_to produces relative links
    Given a fixture app "indexable-app"
    And an empty file named "config.rb"
    And a file named "source/link_to.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index.html", :relative => true %>
    relative: <%= link_to "Relative", "needs_index.html", :relative => true %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index.html", :relative => true %>
    relative: <%= link_to "Relative", "../needs_index.html", :relative => true %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to.html"
    Then I should see 'absolute: <a href="needs_index.html">Needs Index</a>'
    Then I should see 'relative: <a href="needs_index.html">Relative</a>'
    When I go to "/link_to/sub.html"
    Then I should see 'absolute: <a href="../needs_index.html">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index.html">Relative</a>'

  Scenario: relative_link_to produces relative links when :relative_links is set to true
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :relative_links, true
    """
    And a file named "source/link_to.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index.html" %>
    relative: <%= link_to "Relative", "needs_index.html", :relative => false %>
    unknown: <%= link_to "Unknown", "foo.html" %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index.html" %>
    relative: <%= link_to "Relative", "../needs_index.html" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to.html"
    Then I should see 'absolute: <a href="needs_index.html">Needs Index</a>'
    Then I should see 'relative: <a href="/needs_index.html">Relative</a>'
    Then I should see 'unknown: <a href="foo.html">Unknown</a>'
    When I go to "/link_to/sub.html"
    Then I should see 'absolute: <a href="../needs_index.html">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index.html">Relative</a>'