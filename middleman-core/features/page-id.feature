Feature: Page IDs

  Scenario: link_to works with blocks (erb)
    Given the Server is running at "page-id-app"
    When I go to "/index.html"
    Then I should see "I am: index.html"
    And I should see "URL1: /fm.html"
    And I should see "URL2: /2.html"
    And I should see 'URL3: <a href="/3.html">Hi</a>'
    And I should see 'URL4: <a href="/overwrites/from-default.html">Sym</a>'

    When I go to "/fm.html"
    Then I should see "I am: frontmatter"

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
