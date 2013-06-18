Feature: content_tag helper

  Scenario: content_tag doesn't escape content from either block or string
    Given a fixture app "empty-app"
    And an empty file named "config.rb"
    And a file named "source/index.html.erb" with:
    """
    <%= content_tag :div, "<hello>world</hello>", :class => 'one' %>
    <% content_tag :where, :class => 'the hell is' do %>
    <my>damn croissant</my>
    <% end %>
    """
    And the Server is running
    When I go to "index.html"
    Then I should see '<div class="one"><hello>world</hello>'
    And I should see '<where class="the hell is"><my>damn croissant</my>'