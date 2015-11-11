Feature: Minify CSS
  In order reduce bytes sent to client and appease YSlow

  Scenario: Rendering external css with the feature disabled
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false
      """
    And the Server is running at "minify-css-app"
    When I go to "/stylesheets/site.css"
    Then I should see "7" lines
    And I should see "only screen and (device-width"

  Scenario: Rendering external css with the feature enabled
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      activate :minify_css
      """
    And the Server is running at "minify-css-app"
    When I go to "/stylesheets/site.css"
    Then I should see "1" lines
    And I should see "only screen and (device-width"
    When I go to "/more-css/site.css"
    Then I should see "1" lines
    When I go to "/stylesheets/report.css"
    Then I should see "p{border:1px solid #ff6600}"

  Scenario: Rendering external css in a proxied resource
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      activate :minify_css
      proxy '/css-proxy', '/stylesheets/site.css', ignore: true
      """
    And the Server is running at "minify-css-app"
    When I go to "/css-proxy"
    Then I should see "1" lines
    And I should see "only screen and (device-width"

  Scenario: Rendering external css with passthrough compressor
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      module ::PassThrough
        def self.compress(data)
          data
        end
      end

      activate :minify_css, compressor: ::PassThrough
      """
    And the Server is running at "passthrough-app"
    When I go to "/stylesheets/site.css"
    Then I should see "5" lines

  Scenario: Rendering inline css with the feature disabled
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false
      """
    And the Server is running at "minify-css-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style>
      body {
        test: style;
        good: deal;
      }
    </style>
    """

  Scenario: Rendering inline css with a passthrough minifier
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      module ::PassThrough
        def self.compress(data)
          data
        end
      end

      activate :minify_css, inline: true, compressor: ::PassThrough

      page "/inline-css.html", layout: false
      """
    And the Server is running at "passthrough-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style>
      body {
        test: style;
        good: deal; }
    </style>
    """

  Scenario: Rendering inline css with a passthrough minifier using activate-style compressor
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      module ::HelloCompressor
        def self.compress(data)
          "Hello"
        end
      end

      activate :minify_css, inline: true, compressor: ::HelloCompressor

      page "/inline-css.html", layout: false
      """
    And the Server is running at "passthrough-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style>
      Hello
    </style>
    """

  Scenario: Rendering inline css with the feature enabled
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      activate :minify_css, inline: true
      """
    And the Server is running at "minify-css-app"
    When I go to "/inline-css.html"
    Then I should see:
    """
    <style>
      body{test:style;good:deal}
    </style>
    """

  Scenario: Rendering inline css in a PHP document
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      activate :minify_css, inline: true
      """
    And the Server is running at "minify-css-app"
    When I go to "/inline-css.php"
    Then I should see:
    """
    <?='Hello'?>

    <style>
      body{test:style;good:deal}
    </style>
    """

  Scenario: Rendering inline css in a proxied resource
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      activate :minify_css, inline: true
      proxy '/inline-css-proxy', '/inline-css.html', ignore: true
      """
    And the Server is running at "minify-css-app"
    When I go to "/inline-css-proxy"
    Then I should see:
    """
    <style>
      body{test:style;good:deal}
    </style>
    """

  @preserve_mime_types
  Scenario: Configuring content types of resources to be minified
    Given a fixture app "minify-css-app"
    And a file named "config.rb" with:
      """
      config[:sass_source_maps] = false

      mime_type('.xcss', 'text/x-css')
      activate :minify_css, content_types: ['text/x-css'],
                            inline: true,
                            inline_content_types: ['text/html']
      """
    And the Server is running at "minify-css-app"
    When I go to "/stylesheets/site.xcss"
    Then I should see "1" lines
    And I should see "only screen and (device-width"
    When I go to "/inline-css.php"
    Then I should see "8" lines
