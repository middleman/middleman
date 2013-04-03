Feature: i18n manually setting locale

  Scenario: Setting I18n.locale in a block (see issue #809) or with the :lang option
    Given the Server is running at "i18n-force-locale"
    When I go to "/en/index.html"
    Then I should see "Hello"
    Then I should see "I18n.locale: en"
    When I go to "/es/index.html"
    Then I should see "Hola"
    Then I should see "I18n.locale: es"
    When I go to "/fr/index.html"
    Then I should see "Bonjour"
    Then I should see "I18n.locale: fr"
