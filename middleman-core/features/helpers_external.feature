Feature: Helpers in external files

  Scenario: Hello Helper
    Given the Server is running at "external-helpers"
    Then going to "/index.html" should not raise an exception
    And I should see "Hello World"

  Scenario: Automatic Helpers
    Given the Server is running at "external-helpers"
    Then going to "/automatic.html" should not raise an exception
    And I should see "One:Two:Three:Four"

  Scenario: Automatic Helpers Reload
    Given the Server is running at "external-helpers"
    Then going to "/automatic.html" should not raise an exception
    And I should see "One:Two:Three:Four"

    When the file "helpers/one_helper.rb" has the contents
      """
      module OneHelper
        def one
          'Won'
        end
      end
      """
    When the Server is reloaded
    Then going to "/automatic.html" should not raise an exception
    And I should see "Won:Two:Three:Four"
