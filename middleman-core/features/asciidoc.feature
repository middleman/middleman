Feature: AsciiDoc Support
  In order to test included AsciiDoc support

  Scenario: Rendering html
    Given the Server is running at "asciidoc-app"
    When I go to "/hello.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      """

  Scenario: Rendering html with default layout
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      set :layout, :default
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/hello.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!
      Middleman, I am in you.</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with explicit layout
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-layout.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Fallback</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with no layout
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-no-layout.html"
    Then I should see:
      """
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      """

  Scenario: Rendering html using title from document
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-title.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Page Title</title>
      </head>
      <body>
      <h1>Page Title</h1>
      <div id="preamble">
      <div class="sectionbody">
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </div>
      </div>
      </body>
      </html>
      """

  Scenario: Rendering html with title and layout from front matter
    Given the Server is running at "asciidoc-app"
    When I go to "/hello-with-front-matter.html"
    Then I should see:
      """
      <!DOCTYPE html>
      <html>
      <head>
      <title>Page Title</title>
      </head>
      <body>
      <div class="paragraph">
      <p>Hello, AsciiDoc!</p>
      </div>
      </body>
      </html>
      """

  Scenario: Including a file relative to source root
    Given the Server is running at "asciidoc-app"
    When I go to "/master.html"
    Then I should see:
      """
      <div class="literalblock">
      <div class="content">
      <pre>I'm included content.</pre>
      </div>
      """

  Scenario: Linking to an image
    Given the Server is running at "asciidoc-app"
    When I go to "/gallery.html"
    Then I should see:
      """
      <div class="imageblock">
      <div class="content">
      <img src="/images/tiger.gif" alt="tiger">
      </div>
      """

  Scenario: Configuring custom AsciiDoc attributes
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      set :asciidoc_attributes, %w(foo=bar)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/custom-attribute.html"
    Then I should see "bar"

  Scenario: Highlighting source code
    Given a fixture app "asciidoc-app"
    And a file named "config.rb" with:
      """
      set :asciidoc_attributes, %w(source-highlighter=html-pipeline)
      """
    Given the Server is running at "asciidoc-app"
    When I go to "/code.html"
    Then I should see:
      """
      <div class="listingblock">
      <div class="content">
      <pre lang="ruby"><code>puts "Is this mic on?"</code></pre>
      </div>
      </div>
      """
