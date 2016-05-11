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
        home: Home
      """
    And a file named "locales/es.yml" with:
      """
      ---
      es:
        paths:
          hello: "hola"
        msg: Hola
        home: Casa
      """
    And a file named "source/localizable/index.html.erb" with:
      """
      Page: <%= t(:hom) %>
      """
    And a file named "source/localizable/hello.html.erb" with:
      """
      Page: <%= t(:msg) %>

      <%= link_to "Current Home", "/index.html", class: 'current' %>
      <%= link_to "Other Home", "/index.html", title: "Other Home", locale: ::I18n.locale == :en ? :es : :en %>
      <% link_to "/index.html", class: 'current' do %><span>Home: Current Block</span><% end %>
      <% link_to "/index.html", title: "Other Home", locale: ::I18n.locale == :en ? :es : :en do %><span>Home: Other Block</span><% end %>

      <% data.pages.each_with_index do |p, i| %>
        <%= link_to "Current #{p}", "/#{p}", class: 'current' %>
        <%= link_to "Other #{p}", "/#{p}", title: "Other #{p}", locale: ::I18n.locale == :en ? :es : :en %>
        <% link_to "/#{p}", class: 'current' do %><span>Current Block</span><% end %>
        <% link_to "/#{p}", title: "Other #{p}", locale: ::I18n.locale == :en ? :es : :en do %><span>Other Block</span><% end %>
      <% end %>
      """
    And a file named "config.rb" with:
      """
      set :strip_index_file, false
      activate :i18n, mount_at_root: :en
      """
    Given the Server is running at "empty-app"
    When I go to "/hello.html"
    Then I should see "Page: Hello"
    Then I should see '<a href="/index.html" class="current">Current Home</a>'
    Then I should see '<a href="/es/index.html" title="Other Home">Other Home</a>'
    Then I should see '<a href="/index.html" class="current"><span>Home: Current Block</span></a>'
    Then I should see '<a href="/es/index.html" title="Other Home"><span>Home: Other Block</span></a>'
    Then I should see '<a href="/hello.html" class="current">Current hello.html</a>'
    Then I should see '<a href="/es/hola.html" title="Other hello.html">Other hello.html</a>'
    Then I should see '<a href="/hello.html" class="current"><span>Current Block</span></a>'
    Then I should see '<a href="/es/hola.html" title="Other hello.html"><span>Other Block</span></a>'
    When I go to "/es/hola.html"
    Then I should see "Page: Hola"
    Then I should see '<a href="/es/index.html" class="current">Current Home</a>'
    Then I should see '<a href="/index.html" title="Other Home">Other Home</a>'
    Then I should see '<a href="/es/index.html" class="current"><span>Home: Current Block</span></a>'
    Then I should see '<a href="/index.html" title="Other Home"><span>Home: Other Block</span></a>'
    Then I should see '<a href="/es/hola.html" class="current">Current hello.html</a>'
    Then I should see '<a href="/hello.html" title="Other hello.html">Other hello.html</a>'
    Then I should see '<a href="/es/hola.html" class="current"><span>Current Block</span></a>'
    Then I should see '<a href="/hello.html" title="Other hello.html"><span>Other Block</span></a>'

  Scenario: link_to is i18n aware and supports relative_links
    Given a fixture app "empty-app"
    And a file named "locales/en.yml" with:
      """
      ---
      en:
        msg: Hello
        home: Home
      """
    And a file named "locales/es.yml" with:
      """
      ---
      es:
        paths:
          hello: "hola"
        msg: Hola
        home: Casa
      """
    And a file named "source/assets/css/main.css.scss" with:
      """
      $color: red;
      body { background: $color; }
      """
    And a file named "source/localizable/index.html.erb" with:
      """
      Page: <%= t(:home) %>
      <%= stylesheet_link_tag :main %>
      """
    And a file named "source/localizable/hello.html.erb" with:
      """
      Page: <%= t(:msg) %>

      <%= link_to "Current Home", "/index.html", class: 'current' %>
      <%= link_to "Other Home", "/index.html", title: "Other Home", locale: ::I18n.locale == :en ? :es : :en %>
      <% link_to "/index.html", class: 'current' do %><span>Home: Current Block</span><% end %>
      <% link_to "/index.html", title: "Other Home", locale: ::I18n.locale == :en ? :es : :en do %><span>Home: Other Block</span><% end %>

      <%= link_to "Current hello.html", "/hello.html", class: 'current' %>
      <%= link_to "Other hello.html", "/hello.html", title: "Other hello.html", locale: ::I18n.locale == :en ? :es : :en %>
      <% link_to "/hello.html", class: 'current' do %><span>Current Block</span><% end %>
      <% link_to "/hello.html", title: "Other hello.html", locale: ::I18n.locale == :en ? :es : :en do %><span>Other Block</span><% end %>
      """
    And a file named "config.rb" with:
      """
      set :css_dir, 'assets/css'
      set :relative_links, true
      set :strip_index_file, false
      activate :i18n, mount_at_root: :en
      activate :relative_assets
      """
    Given the Server is running at "empty-app"
    When I go to "/index.html"
    Then I should see "assets/css/main.css"
    When I go to "/hello.html"
    Then I should see "Page: Hello"
    Then I should see '<a href="index.html" class="current">Current Home</a>'
    Then I should see '<a href="es/index.html" title="Other Home">Other Home</a>'
    Then I should see '<a href="index.html" class="current"><span>Home: Current Block</span></a>'
    Then I should see '<a href="es/index.html" title="Other Home"><span>Home: Other Block</span></a>'
    Then I should see '<a href="hello.html" class="current">Current hello.html</a>'
    Then I should see '<a href="es/hola.html" title="Other hello.html">Other hello.html</a>'
    Then I should see '<a href="hello.html" class="current"><span>Current Block</span></a>'
    Then I should see '<a href="es/hola.html" title="Other hello.html"><span>Other Block</span></a>'
    When I go to "/es/hola.html"
    Then I should see "Page: Hola"
    Then I should see '<a href="index.html" class="current">Current Home</a>'
    Then I should see '<a href="../index.html" title="Other Home">Other Home</a>'
    Then I should see '<a href="index.html" class="current"><span>Home: Current Block</span></a>'
    Then I should see '<a href="../index.html" title="Other Home"><span>Home: Other Block</span></a>'
    Then I should see '<a href="hola.html" class="current">Current hello.html</a>'
    Then I should see '<a href="../hello.html" title="Other hello.html">Other hello.html</a>'
    Then I should see '<a href="hola.html" class="current"><span>Current Block</span></a>'
    Then I should see '<a href="../hello.html" title="Other hello.html"><span>Other Block</span></a>'

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
      activate :i18n, mount_at_root: :en
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
