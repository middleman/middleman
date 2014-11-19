Feature: Directory Index
  In order output Apache-friendly directories and indexes

  Scenario: Checking built folder for content
    Given a successfully built app at "indexable-app"
    When I cd to "build"
    Then the following files should exist:
      | needs_index/index.html                        |
      | a_folder/needs_index/index.html               |
      | leave_me_alone.html                           |
      | wildcard_leave_me_alone.html                  |
      | evil spaces/index.html                        |
      | regular/index.html                            |
      | .htaccess                                     |
      | .htpasswd                                     |
      | .nojekyll                                     |
    Then the following files should not exist:
      | egular/index/index.html                       |
      | needs_index.html                              |
      | evil spaces.html                              |
      | a_folder/needs_index.html                     |
      | leave_me_alone/index.html                     |
      | wildcard_leave_me_alone/index.html            |
    And the file "needs_index/index.html" should contain "Indexable"
    And the file "a_folder/needs_index/index.html" should contain "Indexable"
    And the file "leave_me_alone.html" should contain "Stay away"
    And the file "regular/index.html" should contain "Regular"
    And the file "evil spaces/index.html" should contain "Filled with Evil Spaces"
    
  Scenario: Preview normal file
    Given the Server is running at "indexable-app"
    When I go to "/needs_index/"
    Then I should see "Indexable"
    
  Scenario: Preview normal file with spaces in filename
    Given the Server is running at "indexable-app"
    When I go to "/evil spaces/"
    Then I should see "Filled with Evil Spaces"

  Scenario: Preview normal file subdirectory
    Given the Server is running at "indexable-app"
    When I go to "/a_folder/needs_index/"
    Then I should see "Indexable"
    
  Scenario: Preview ignored file
    Given the Server is running at "indexable-app"
    When I go to "/leave_me_alone/"
    Then I should see "File Not Found"

  Scenario: Link_to knows about directory indexes
    Given a fixture app "indexable-app"
    And a file named "source/link_to.html.erb" with:
    """
    link_to: <%= link_to "Needs Index", "/needs_index.html" %>
    explicit_link_to: <%= link_to "Explicit", "/needs_index/index.html" %>
    unknown_link_to: <%= link_to "Unknown", "/unknown.html" %>
    relative_link_to: <%= link_to "Relative", "needs_index.html" %>
    link_to_with_spaces: <%= link_to "Spaces", "/evil%20spaces.html" %>
    """
    And a file named "source/link_to/sub.html.erb" with:
    """
    link_to: <%= link_to "Needs Index", "/needs_index.html" %>
    explicit_link_to: <%= link_to "Explicit", "/needs_index/index.html" %>
    unknown_link_to: <%= link_to "Unknown", "/unknown.html" %>
    relative_link_to: <%= link_to "Relative", "../needs_index.html" %>
    link_to_with_spaces: <%= link_to "Spaces", "../evil%20spaces.html" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/link_to/"
    Then I should see 'link_to: <a href="/needs_index/">Needs Index</a>'
    Then I should see 'explicit_link_to: <a href="/needs_index/index.html">Explicit</a>'
    Then I should see 'unknown_link_to: <a href="/unknown.html">Unknown</a>'
    Then I should see 'relative_link_to: <a href="/needs_index/">Relative</a>'
    Then I should see 'link_to_with_spaces: <a href="/evil%20spaces/">Spaces</a>'
    When I go to "/link_to/sub/"
    Then I should see 'link_to: <a href="/needs_index/">Needs Index</a>'
    Then I should see 'explicit_link_to: <a href="/needs_index/index.html">Explicit</a>'
    Then I should see 'unknown_link_to: <a href="/unknown.html">Unknown</a>'
    Then I should see 'relative_link_to: <a href="/needs_index/">Relative</a>'
    Then I should see 'link_to_with_spaces: <a href="/evil%20spaces/">Spaces</a>'

