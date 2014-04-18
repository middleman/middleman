Feature: link_to helper with Japanese characters

  Scenario: link_to produces URI escaped relative links which include Japanese characters
    Given a fixture app "indexable-ja-app"
    And an empty file named "config.rb"
    And a file named "source/link_to.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html", :relative => true %>
    relative: <%= link_to "Relative", "needs_index_日本語.html", :relative => true %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html", :relative => true %>
    relative: <%= link_to "Relative", "../needs_index_日本語.html", :relative => true %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to.html"
    Then I should see 'absolute: <a href="needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Needs Index</a>'
    Then I should see 'relative: <a href="needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Relative</a>'
    When I go to "/link_to/sub.html"
    Then I should see 'absolute: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Relative</a>'

  Scenario: link_to produces relative links which include Japanese characters when :relative_links is set to true
    Given a fixture app "indexable-ja-app"
    And a file named "config.rb" with:
    """
    set :relative_links, true
    """
    And a file named "source/link_to.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html" %>
    relative: <%= link_to "Relative", "needs_index_日本語.html", :relative => false %>
    unknown: <%= link_to "Unknown", "foo.html" %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html" %>
    relative: <%= link_to "Relative", "../needs_index_日本語.html" %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to.html"
    Then I should see 'absolute: <a href="needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Needs Index</a>'
    Then I should see 'relative: <a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Relative</a>'
    Then I should see 'unknown: <a href="foo.html">Unknown</a>'
    When I go to "/link_to/sub.html"
    Then I should see 'absolute: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Relative</a>'

  Scenario: link_to knows about directory indexes (include Japanese characters)
    Given a fixture app "indexable-ja-app"
    And a file named "source/link_to.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html", :relative => true %>
    relative: <%= link_to "Relative", "needs_index_日本語.html", :relative => true %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    absolute: <%= link_to "Needs Index", "/needs_index_日本語.html", :relative => true %>
    relative: <%= link_to "Relative", "../needs_index_日本語.html", :relative => true %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to/"
    Then I should see 'absolute: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/">Needs Index</a>'
    Then I should see 'relative: <a href="../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/">Relative</a>'
    When I go to "/link_to/sub/"
    Then I should see 'absolute: <a href="../../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/">Needs Index</a>'
    Then I should see 'relative: <a href="../../needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/">Relative</a>'

  Scenario: link_to can take a Resource which include Japanese characters
    Given a fixture app "indexable-ja-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index", sitemap.find_resource_by_path("/needs_index_日本語.html") %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/">Needs Index</a>'

  Scenario: Setting http_prefix (include Japanese characters)
    Given a fixture app "indexable-ja-app"
    And a file named "config.rb" with:
    """
    set :http_prefix, "/foo"
    """
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index", "/needs_index_日本語.html" %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to.html"
    Then I should see '<a href="/foo/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E.html">Needs Index</a>'

  Scenario: link_to preserves query string and anchor which include Japanese characters and isn't messed up by them
    Given a fixture app "indexable-ja-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index Anchor", "/needs_index_日本語.html#☆" %>
    <%= link_to "Needs Index Query", "/needs_index_日本語.html?☆" %>
    <%= link_to "Needs Index Query and Anchor", "/needs_index_日本語.html?☆#☆" %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/#%E2%98%86">Needs Index Anchor</a>'
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/?%E2%98%86">Needs Index Query</a>'
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/?%E2%98%86#%E2%98%86">Needs Index Query and Anchor</a>'

  Scenario: link_to accepts a :query option that appends a query string (include Japanese characters)
    Given a fixture app "indexable-ja-app"
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "Needs Index String", "/needs_index_日本語.html", :query => "☆" %>
    <%= link_to "Needs Index Hash", "/needs_index_日本語.html", :query => { :☆ => :★ } %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to/"
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/?%E2%98%86">Needs Index String</a>'
    Then I should see '<a href="/needs_index_%E6%97%A5%E6%9C%AC%E8%AA%9E/?%E2%98%86=%E2%98%85">Needs Index Hash</a>'
   
   Scenario: link_to produces a Punycode encoded link
    Given a fixture app "indexable-ja-app"
    And a file named "config.rb" with:
    """
    set :http_prefix, "/"
    """
    And a file named "source/link_to.html.erb" with:
    """
    <%= link_to "日本語.jp", "http://日本語.jp/" %>
    """
    And the Server is running at "indexable-ja-app"
    When I go to "/link_to.html"
    Then I should see '<a href="http://xn--wgv71a119e.jp/">日本語.jp</a>'
