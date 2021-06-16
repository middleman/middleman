Feature: Relative Assets
  In order easily switch between relative and absolute paths

  Scenario: Previewing css with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should not see "url('../"
    And I should see '/images/blank.gif")'

  Scenario: Building css with the feature disabled
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "stylesheets/relative_assets.css" should contain 'url("/images/blank.gif")'

  Scenario: Rendering html with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image.html"
    Then I should see '"/stylesheets/relative_assets.css"'
    Then I should see '"/javascripts/app.js"'
    Then I should see "/images/blank.gif"
    When I go to "/absolute_image_relative_css.html"
    Then I should see '"stylesheets/relative_assets.css"'
    Then I should see '"javascripts/app.js"'
    Then I should see "/images/blank.gif"

  Scenario: Rendering css with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see 'url("../images/blank.gif'
    When I go to "/javascripts/application.js"
    Then I should not see "../"
    When I go to "/stylesheets/fonts.css"
    Then I should see 'url(../fonts/roboto/roboto-regular-webfont.eot'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.woff'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.ttf'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.svg'
    When I go to "/stylesheets/fonts2.css"
    Then I should see 'url(../fonts/roboto/roboto-regular-webfont.eot'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.woff'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.ttf'
    And I should see 'url(../fonts/roboto/roboto-regular-webfont.svg'

  Scenario: Building css with the feature enabled
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "stylesheets/relative_assets.css" should contain 'url("../images/blank.gif")'
    Then the file "javascripts/application.js" should not contain "../"

  Scenario: Relative css reference with directory indexes
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      activate :relative_assets
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "relative_image/index.html" should contain "../stylesheets/relative_assets.css"

  Scenario: Rendering html with the feature enabled (overrides relative option on helpers)
    Given "relative_assets" feature is "enabled"
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image.html"
    Then I should see '"stylesheets/relative_assets.css"'
    Then I should see '"javascripts/app.js"'
    When I go to "/relative_image_absolute_css.html"
    Then I should see '"stylesheets/relative_assets.css"'
    Then I should see '"javascripts/app.js"'
    Then I should not see "/images/blank.gif"
    And I should see "images/blank.gif"

  Scenario: Rendering scss with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "fonts-app"
    When I go to "/stylesheets/fonts.css"
    Then I should see:
      """
      url("../fonts/StMarie-Thin.otf"
      """
    And I should see:
      """
      url("../fonts/blank/blank.otf"
      """

  Scenario: Building scss with the feature enabled
    Given a fixture app "fonts-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given a successfully built app at "fonts-app"
    When I cd to "build"
    Then the file "stylesheets/fonts.css" should contain:
      """
      url("../fonts/StMarie-Thin.otf")
      """
    And the file "stylesheets/fonts.css" should contain:
      """
      url("../fonts/blank/blank.otf")
      """

  Scenario: Relative assets via image_tag
    Given a fixture app "relative-assets-app"
    Given "relative_assets" feature is "enabled"
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag '/img/blank.gif' %>
      """
    And the Server is running
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="../img/blank.gif"'

  Scenario: Relative assets should not break data URIs in image_tag
    Given a fixture app "relative-assets-app"
    Given "relative_assets" feature is "enabled"
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" %>
      """
    And the Server is running
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />'

  Scenario: URLs are not rewritten for rewrite ignored paths
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets, rewrite_ignore: [
        '/stylesheets/fonts.css',
      ]
      """
    And the Server is running
    When I go to "/stylesheets/relative_assets.css"
    Then I should see 'url("../images/blank.gif'
    When I go to "/stylesheets/fonts.css"
    Then I should see 'url(/fonts/roboto/roboto-regular-webfont.eot'
