Feature: relative_link_to helper

  Scenario: relative_link_to knows about directory indexes
    Given a fixture app "indexable-app"
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
    When I go to "/link_to/"
    Then I should see 'absolute: <a href="needs_index/">Needs Index</a>'
    Then I should see 'relative: <a href="needs_index/">Relative</a>'
    When I go to "/link_to/sub/"
    Then I should see 'absolute: <a href="../needs_index/">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index/">Relative</a>'