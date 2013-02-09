Feature: url_for helper

  Scenario: url_for produces relative links
    Given a fixture app "indexable-app"
    And an empty file named "config.rb"
    And a file named "source/url_for.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html", :relative => true %>
    relative: <%= url_for "needs_index.html", :relative => true %>
    """
    And a file named "source/url_for/sub.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html", :relative => true %>
    relative: <%= url_for "../needs_index.html", :relative => true %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for.html"
    Then I should see 'absolute: needs_index.html'
    Then I should see 'relative: needs_index.html'
    When I go to "/url_for/sub.html"
    Then I should see 'absolute: ../needs_index.html'
    Then I should see 'relative: ../needs_index.html'

  Scenario: url_for relative works with strip_index_file
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :relative_links, true
    set :strip_index_file, true
    helpers do
      def menu_items(path='url_for.html')
        sitemap.find_resource_by_destination_path(path).children
      end
    end
    """
    And a file named "source/url_for.html.erb" with:
    """
    <% menu_items.each do |item| %>
        "<%= url_for(item.url) %>"
        "<%= url_for(item) %>"
    <% end %>
    """
    And a file named "source/url_for/sub.html.erb" with:
    """
    <% menu_items.each do |item| %>
        "<%= url_for(item.url) %>"
        "<%= url_for(item) %>"
    <% end %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for.html"
    Then I should see '"url_for/sub.html"'
    Then I should not see "/url_for/sub.html"
    When I go to "/url_for/sub.html"
    Then I should see '"sub.html"'
    Then I should not see "/url_for/sub.html"

  Scenario: url_for produces relative links when :relative_links is set to true
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :relative_links, true
    """
    And a file named "source/url_for.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html" %>
    relative: <%= url_for "needs_index.html", :relative => false %>
    unknown: <%= url_for "foo.html" %>
    """
    And a file named "source/url_for/sub.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html" %>
    relative: <%= url_for "../needs_index.html" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for.html"
    Then I should see 'absolute: needs_index.html'
    Then I should see 'relative: /needs_index.html'
    Then I should see 'unknown: foo.html'
    When I go to "/url_for/sub.html"
    Then I should see 'absolute: ../needs_index.html'
    Then I should see 'relative: ../needs_index.html'
  
  Scenario: url_for knows about directory indexes
    Given a fixture app "indexable-app"
    And a file named "source/url_for.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html", :relative => true %>
    relative: <%= url_for "needs_index.html", :relative => true %>
    """
    And a file named "source/url_for/sub.html.erb" with:
    """
    absolute: <%= url_for "/needs_index.html", :relative => true %>
    relative: <%= url_for "../needs_index.html", :relative => true %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for/"
    Then I should see 'absolute: ../needs_index/'
    Then I should see 'relative: ../needs_index/'
    When I go to "/url_for/sub/"
    Then I should see 'absolute: ../../needs_index/'
    Then I should see 'relative: ../../needs_index/'

  Scenario: url_for can take a Resource
    Given a fixture app "indexable-app"
    And a file named "source/url_for.html.erb" with:
    """
    "<%= url_for sitemap.find_resource_by_path("/needs_index.html") %>"
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for/"
    Then I should see '"/needs_index/"'

  Scenario: Setting http_prefix
    Given a fixture app "indexable-app"
    And a file named "config.rb" with:
    """
    set :http_prefix, "/foo"
    """
    And a file named "source/url_for.html.erb" with:
    """
    <%= url_for "/needs_index.html" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for.html"
    Then I should see '/foo/needs_index.html'

  Scenario: url_for preserves query string and anchor and isn't messed up by them
    Given a fixture app "indexable-app"
    And a file named "source/url_for.html.erb" with:
    """
    Needs Index Anchor <%= url_for "/needs_index.html#foo" %>
    Needs Index Query <%= url_for "/needs_index.html?foo" %>
    Needs Index Query and Anchor <%= url_for "/needs_index.html?foo#foo" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for/"
    Then I should see 'Needs Index Anchor /needs_index/#foo'
    Then I should see 'Needs Index Query /needs_index/?foo'
    Then I should see 'Needs Index Query and Anchor /needs_index/?foo#foo'

  Scenario: url_for accepts a :query option that appends a query string
    Given a fixture app "indexable-app"
    And a file named "source/url_for.html.erb" with:
    """
    Needs Index String <%= url_for "/needs_index.html", :query => "foo" %>
    Needs Index Hash <%= url_for "/needs_index.html", :query => { :foo => :bar } %>
    """
    And the Server is running at "indexable-app"
    When I go to "/url_for/"
    Then I should see 'Needs Index String /needs_index/?foo'
    Then I should see 'Needs Index Hash /needs_index/?foo=bar'
