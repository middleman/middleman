Feature: i18n Links

  Scenario: A template changes i18n during preview
    Given a fixture app "empty-app"
    And a file named "data/pages.yml" with:
      """
      - hello.html 
      """
    And a file named "locales/en.yml" with:
      """
      ---
      en:
        msg: Hello
      """
    And a file named "locales/es.yml" with:
      """
      ---
      es:
        paths:
          hello: "hola"
        msg: Hola
      """
    And a file named "source/localizable/hello.html.erb" with:
      """
      Page: <%= t(:msg) %>
      <% data.pages.each_with_index do |p, i| %>
        <%= link_to "Current #{p}", "/#{p}" %>
        <%= link_to "Other #{p}", "/#{p}", lang: ::I18n.locale == :en ? :es : :en %>
      <% end %>
      """
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "empty-app"
    When I go to "/hello.html"
    Then I should see "Page: Hello"
    Then I should see '<a href="/hello.html">Current hello.html</a>'
    Then I should see '<a href="/es/hola.html">Other hello.html</a>'
    When I go to "/es/hola.html"
    Then I should see "Page: Hola"
    Then I should see '<a href="/es/hola.html">Current hello.html</a>'
    Then I should see '<a href="/hello.html">Other hello.html</a>'