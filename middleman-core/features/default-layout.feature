Feature: Describe which files get layouts

  Background:
    Given an empty app
    And a file named "config.rb" with:
      """
      page "/about.html", layout: :layout2
      """
    And a file named "source/layouts/layout.erb" with:
      """
      In Layout
      <%= yield %>
      """
    And a file named "source/layouts/layout2.erb" with:
      """
      <root>
        <title>Second Layout</title>
        <%= yield %>
      </root>
      """
    And a file named "source/index.html.erb" with:
      """
      In Index
      """
    And a file named "source/about.html.erb" with:
      """
      In About
      """
    And a file named "source/style.css.scss" with:
      """
      html { border: 1; }
      """
    And a file named "source/style2.scss" with:
      """
      html { border: 2; }
      """
    And a file named "source/data.json" with:
      """
      { "hello": "world" }
      """
    And a file named "source/script.js" with:
      """
      helloWorld();
      """
    And a file named "source/test.xml.erb" with:
      """
      ---
      layout: layout2
      ---

      <test>Hi</test>
      """
    And the Server is running at "empty_app"

  Scenario: Normal Template
    When I go to "/index.html"
    Then I should see "In Index"
    And I should see "In Layout"

  Scenario: Normal Template with override
    When I go to "/about.html"
    Then I should see "In About"
    And I should see "Second Layout"
    And I should not see "In Layout"

  Scenario: Sass
    When I go to "/style.css"
    Then I should see "border: 1"
    And I should not see "In Layout"

  Scenario: Sass with extension
    When I go to "/style2"
    Then I should see "border: 2"
    And I should not see "In Layout"

  Scenario: JSON
    When I go to "/data.json"
    Then I should see "hello"
    And I should not see "In Layout"

  Scenario: JS
    When I go to "/script.js"
    Then I should see "helloWorld()"
    And I should not see "In Layout"

  Scenario: XML
    When I go to "/test.xml"
    Then I should see "<test>Hi</test>"
    And I should see "<title>Second Layout</title>"

