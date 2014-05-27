Feature: form_tag helper

  Scenario: form_tag produces relative links
    Given a fixture app "indexable-app"
    And an empty file named "config.rb"
    And a file named "source/form_tag.html.erb" with:
    """
    absolute: <% form_tag "/needs_index.html#absolute", relative: true do %>
    <% end %>
    relative: <% form_tag "needs_index.html#relative", relative: true do %>
    <% end %>
    """
    And a file named "source/form_tag/sub.html.erb" with:
    """
    absolute: <% form_tag "/needs_index.html#absolute", relative: true do %>
    <% end %>
    relative: <% form_tag "../needs_index.html#relative", relative: true do %>
    <% end %>
    """
    And the Server is running at "indexable-app"
    When I go to "/form_tag.html"
    Then I should see 'action="needs_index.html#absolute"'
    Then I should see 'action="needs_index.html#relative"'
    When I go to "/form_tag/sub.html"
    Then I should see 'action="../needs_index.html#absolute"'
    Then I should see 'action="../needs_index.html#relative"'
