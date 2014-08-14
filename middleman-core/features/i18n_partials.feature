Feature: i18n Partials

  Scenario: Running localize with the default config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/partials/index.html"
    Then I should see "Country: USA"
    Then I should see "State: District of Columbia"
    Then I should see "Greeting: Hello"
    Then I should see "Site: Locale Site"
    Then I should see "Flag: stars"
    Then I should see "President: obama"
    When I go to "/es/partials/index.html"
    Then I should see "Country: Mexico"
    Then I should see "State: Distrito Federal"
    Then I should see "Greeting: Hola"
    Then I should see "Site: Locale Site"
    Then I should see "Flag: bars"
    Then I should see "President: nieto"