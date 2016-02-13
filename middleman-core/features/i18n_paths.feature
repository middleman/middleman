Feature: i18n Paths

  Scenario: Linking to a page in a language-agnostic way
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see '<a href="/morning.html">'
    When I go to "/es"
    Then I should see '<a href="/es/manana.html">'
    When I go to "/morning.html"
    Then I should see "Good morning"
    When I go to "/es/manana.html"
    Then I should see "Buenos días"

  Scenario: Locale-switching link
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see '<a href="/es/">es</a>'
    When I go to "/es"
    Then I should see '<a href="/">en</a>'
    When I go to "/morning.html"
    Then I should see '<a href="/es/manana.html">es</a>'
    When I go to "/es/manana.html"
    Then I should see '<a href="/morning.html">en</a>'
