Feature: i18n Paths

  Scenario: link_to is i18n aware
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
        <%= link_to "Current #{p}", "/#{p}", class: 'current' %>
        <%= link_to "Other #{p}", "/#{p}", title: "Other #{p}", locale: ::I18n.locale == :en ? :es : :en %>
        <% link_to "/#{p}", class: 'current' do %><span>Current Block</span><% end %>
        <% link_to "/#{p}", title: "Other #{p}", locale: ::I18n.locale == :en ? :es : :en do %><span>Other Block</span><% end %>
      <% end %>
      """
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "empty-app"
    When I go to "/hello.html"
    Then I should see "Page: Hello"
    Then I should see '<a class="current" href="/hello.html">Current hello.html</a>'
    Then I should see '<a title="Other hello.html" href="/es/hola.html">Other hello.html</a>'
    Then I should see '<a class="current" href="/hello.html"><span>Current Block</span></a>'
    Then I should see '<a title="Other hello.html" href="/es/hola.html"><span>Other Block</span></a>'
    When I go to "/es/hola.html"
    Then I should see "Page: Hola"
    Then I should see '<a class="current" href="/es/hola.html">Current hello.html</a>'
    Then I should see '<a title="Other hello.html" href="/hello.html">Other hello.html</a>'
    Then I should see '<a class="current" href="/es/hola.html"><span>Current Block</span></a>'
    Then I should see '<a title="Other hello.html" href="/hello.html"><span>Other Block</span></a>'

  Scenario: url_for is i18n aware
    Given a fixture app "empty-app"
    And a file named "data/pages.yml" with:
      """
      - hello.html 
      - article.html
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
        Current: <%= url_for "/#{p}" %>
        Other: <%= url_for "/#{p}", locale: ::I18n.locale == :en ? :es : :en %>
      <% end %>
      """
    And a file named "source/localizable/article.html.erb" with:
      """
      Page Lang: Default

      Current: <%= url_for "/article.html" %>
      Other: <%= url_for "/article.html", locale: ::I18n.locale == :en ? :es : :en %>
      """
    And a file named "source/localizable/article.es.html.erb" with:
      """
      Page Lang: Spanish

      Current: <%= url_for "/article.html" %>
      Other: <%= url_for "/article.html", locale: :en %>
      """
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "empty-app"
    When I go to "/hello.html"
    Then I should see "Page: Hello"
    Then I should see 'Current: /hello.html'
    Then I should see 'Other: /es/hola.html'
    When I go to "/es/hola.html"
    Then I should see "Page: Hola"
    Then I should see 'Current: /es/hola.html'
    Then I should see 'Other: /hello.html'
    When I go to "/article.html"
    Then I should see "Page Lang: Default"
    Then I should see 'Current: /article.html'
    Then I should see 'Other: /es/article.html'
    When I go to "/es/article.html"
    Then I should see "Page Lang: Spanish"
    Then I should see 'Current: /es/article.html'
    Then I should see 'Other: /article.html'
