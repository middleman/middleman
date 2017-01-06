Feature: Page IDs

  Scenario: link_to works with blocks (erb)
    Given the Server is running at "page-id-app"
    When I go to "/index.html"
    Then I should see "I am: index"
    And I should see "URL1: /fm.html"
    And I should see "URL2: /2.html"
    And I should see 'URL3: <a href="/3.html">Hi</a>'
    And I should see 'URL4: <a href="/overwrites/from-default.html">Sym</a>'
    And I should see 'URL5: <a href="/implicit.html">Imp</a>'
    And I should see 'URL6: <a href="/folder/foldern.html">Foldern</a>'
    And I should see 'URL7: <a href="/feed.xml">Feed</a>'
    And I should see "URL8: /fourty-two.html"

    When I go to "/fm.html"
    Then I should see "I am: frontmatter"
    When I go to "/implicit.html"
    Then I should see "I am: implicit"
    When I go to "/feed.xml"
    Then I should see "I am: feed.xml"
    When I go to "/folder/foldern.html"
    Then I should see "I am: folder/foldern"

    When I go to "/1.html"
    Then I should see "I am: page1"
    When I go to "/2.html"
    Then I should see "I am: page2"
    When I go to "/3.html"
    Then I should see "I am: page3"

    When I go to "/overwrites/from-default.html"
    Then I should see "I am: something-else"

    When I go to "/overwrites/from-frontmatter.html"
    Then I should see "I am: from_frontmatter"

  Scenario: Override page ID derivation with a proc
    Given a fixture app "page-id-app"
    And app "page-id-app" is using config "proc"
    And the Server is running at "page-id-app"

    When I go to "/index.html"
    Then I should see "I am: index.html-foo"
    And I should see "URL1: /fm.html"
    And I should see "URL2: /2.html"
    And I should see 'URL3: <a href="/3.html">Hi</a>'
    And I should see 'URL4: <a href="/overwrites/from-default.html">Sym</a>'
    And I should see "URL8: /fourty-two.html"
    And I should see 'URL9: <a href="/implicit.html">Imp</a>'
    And I should see 'URL10: <a href="/folder/foldern.html">Foldern</a>'
    And I should see 'URL11: <a href="/feed.xml">Feed</a>'

    When I go to "/fm.html"
    Then I should see "I am: frontmatter"
    When I go to "/implicit.html"
    Then I should see "I am: implicit.html-foo"
    When I go to "/feed.xml"
    Then I should see "I am: feed.xml-foo"
    When I go to "/folder/foldern.html"
    Then I should see "I am: folder/foldern.html-foo"

    When I go to "/1.html"
    Then I should see "I am: page1"
    When I go to "/2.html"
    Then I should see "I am: page2"
    When I go to "/3.html"
    Then I should see "I am: page3"

    When I go to "/overwrites/from-default.html"
    Then I should see "I am: something-else"

    When I go to "/overwrites/from-frontmatter.html"
    Then I should see "I am: from_frontmatter"
