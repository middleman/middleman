Feature: Relative Assets (Helpers Only)

  Scenario: Rendering css with the feature enabled
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets, helpers_only: true
      """
    And a file named "source/stylesheets/relative_assets.css.sass.erb" with:
      """
      h1
        background: url("<%= asset_url('images/blank.gif') %>")
      h2
        background: url("<%= asset_url('/images/blank2.gif') %>")
      """
    And a file named "source/javascripts/application.js.erb" with:
      """
      function foo() {
        var img = document.createElement('img');
        img.src = '<%= asset_url("images/100px.jpg") %>';
        var body = document.getElementsByTagName('body')[0];
        body.insertBefore(img, body.firstChild);
      }

      window.onload = foo;
      """
    And a file named "source/stylesheets/fonts3.css.erb" with:
      """
      @font-face {
        font-family: 'Roboto2';
        src: url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.eot") %>);
        src: url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.eot?#iefix") %>) format('embedded-opentype'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.woff") %>) format('woff'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.ttf") %>) format('truetype'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.svg#robotoregular") %>) format('svg');
        font-weight: normal;
        font-style: normal;
      }
      """
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see 'url("../images/blank.gif'
    And I should see 'url("../images/blank2.gif'
    When I go to "/javascripts/application.js"
    Then I should not see "../"
    When I go to "/stylesheets/fonts3.css"
    Then I should see 'url(../fonts/roboto/roboto-regular-webfont.eot'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.woff'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.ttf'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.svg'

  Scenario: Relative css reference with directory indexes
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      activate :relative_assets, helpers_only: true
      """
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image/index.html"
    Then I should see "../stylesheets/relative_assets.css"

  Scenario: Relative assets via image_tag
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets, helpers_only: true
      """
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag '/img/blank.gif' %>
      """
    And the Server is running at "relative-assets-app"
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="../img/blank.gif"'

  Scenario: Relative assets should not break data URIs in image_tag
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets, helpers_only: true
      """
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" %>
      """
    And the Server is running at "relative-assets-app"
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />'

  Scenario: URLs are not rewritten for rewrite ignored paths
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets, rewrite_ignore: [
        '/stylesheets/fonts3.css',
      ], helpers_only: true
      """
    And a file named "source/stylesheets/relative_assets.css.sass.erb" with:
      """
      h1
        background: url("<%= asset_url('images/blank.gif') %>")
      h2
        background: url("<%= asset_url('/images/blank2.gif') %>")
      """
    And a file named "source/stylesheets/fonts3.css.erb" with:
      """
      @font-face {
        font-family: 'Roboto2';
        src: url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.eot") %>);
        src: url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.eot?#iefix") %>) format('embedded-opentype'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.woff") %>) format('woff'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.ttf") %>) format('truetype'),
            url(<%= asset_url("/fonts/roboto/roboto-regular-webfont.svg#robotoregular") %>) format('svg');
        font-weight: normal;
        font-style: normal;
      }
      """
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see 'url("../images/blank.gif'
    When I go to "/stylesheets/fonts3.css"
    Then I should see 'url(/fonts/roboto/roboto-regular-webfont.eot'
