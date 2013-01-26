Feature: link_to helper

  Scenario: link_to produces relative links
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

  Scenario: link_to relative works with strip_index_file
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :relative_links, true
    set :strip_index_file, true
    helpers do
      def menu_items(path='link_to.html')
        sitemap.find_resource_by_destination_path(path).children
      end
    end
    """
    And a file named "source/link_to.html.erb" with:
    """
    <% menu_items.each do |item| %>
        <%= link_to(item.metadata[:page]['title'], item.url) %>
        <%= link_to(item.metadata[:page]['title'], item) %>
    <% end %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    <% menu_items.each do |item| %>
        <%= link_to(item.metadata[:page]['title'], item.url) %>
        <%= link_to(item.metadata[:page]['title'], item) %>
    <% end %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to.html"
    Then I should see '"link_to/sub.html"'
    Then I should not see "/link_to/sub.html"
    When I go to "/link_to/sub.html"
    Then I should see '"sub.html"'
    Then I should not see "/link_to/sub.html"

  Scenario: link_to produces relative links when :relative_links is set to true
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
  
  Scenario: link_to knows about directory indexes
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
    Then I should see 'absolute: <a href="../needs_index/">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index/">Relative</a>'
    When I go to "/link_to/sub/"
    Then I should see 'absolute: <a href="../../needs_index/">Needs Index</a>'
    Then I should see 'relative: <a href="../../needs_index/">Relative</a>'

  Scenario: link_to can take a Resource
    Given a fixture app "indexable-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index", sitemap.find_resource_by_path("/needs_index.html") %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index/">Needs Index</a>'

  Scenario: Setting http_prefix
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :http_prefix, "/foo"
    """
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index", "/needs_index.html" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to.html"
    Then I should see '<a href="/foo/needs_index.html">Needs Index</a>'

  Scenario: link_to preserves query string and anchor and isn't messed up by them
    Given a fixture app "indexable-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index Anchor", "/needs_index.html#foo" %>
    <%= link_to "Needs Index Query", "/needs_index.html?foo" %>
    <%= link_to "Needs Index Query and Anchor", "/needs_index.html?foo#foo" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index/#foo">Needs Index Anchor</a>'
    Then I should see '<a href="/needs_index/?foo">Needs Index Query</a>'
    Then I should see '<a href="/needs_index/?foo#foo">Needs Index Query and Anchor</a>'

  Scenario: link_to accepts a :query option that appends a query string
    Given a fixture app "indexable-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index String", "/needs_index.html", :query => "foo" %>
    <%= link_to "Needs Index Hash", "/needs_index.html", :query => { :foo => :bar } %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index/?foo">Needs Index String</a>'
    Then I should see '<a href="/needs_index/?foo=bar">Needs Index Hash</a>'
