Feature: Relative Assets
  In order easily switch between relative and absolute paths

  Scenario: Previewing css with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should not see "url('../"
    And I should see "/images/blank.gif')"

  Scenario: Building css with the feature disabled
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "stylesheets/relative_assets.css" should contain "url('/images/blank.gif')"

  Scenario: Rendering html with the feature disabled
    Given "relative_assets" feature is "disabled"
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image.html"
    Then I should see "/images/blank.gif"

  Scenario: Rendering css with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "url('../images/blank.gif"

  Scenario: Building css with the feature enabled
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "stylesheets/relative_assets.css" should contain "url('../images/blank.gif')"

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

  Scenario: Rendering html with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image.html"
    Then I should not see "/images/blank.gif"
    And I should see "images/blank.gif"

  Scenario: Rendering css with a custom images_dir
    Given "relative_assets" feature is "enabled"
    And "images_dir" is set to "img"
    And the Server is running at "relative-assets-app"
    When I go to "/stylesheets/relative_assets.css"
    Then I should see "url('../img/blank.gif')"

  Scenario: Building css with a custom images_dir
    Given a fixture app "relative-assets-app"
    And a file named "config.rb" with:
      """
      set :images_dir, "img"
      activate :relative_assets
      """
    Given a successfully built app at "relative-assets-app"
    When I cd to "build"
    Then the file "stylesheets/relative_assets.css" should contain "url('../img/blank.gif')"

  Scenario: Rendering html with a custom images_dir
    Given "relative_assets" feature is "enabled"
    And "images_dir" is set to "img"
    And the Server is running at "relative-assets-app"
    When I go to "/relative_image.html"
    Then I should not see "/images/blank.gif"
    Then I should not see "/img/blank.gif"
    And I should see "img/blank.gif"

  Scenario: Rendering scss with the feature enabled
    Given "relative_assets" feature is "enabled"
    And the Server is running at "fonts-app"
    When I go to "/stylesheets/fonts.css"
    Then I should see "url('../fonts/StMarie-Thin.otf"
    And I should see "url('../fonts/blank/blank.otf"

  Scenario: Rendering scss with the feature enabled and a custom fonts_dir
    Given "relative_assets" feature is "enabled"
    And "fonts_dir" is set to "otf"
    And the Server is running at "fonts-app"
    When I go to "/stylesheets/fonts.css"
    Then I should not see "url('../fonts/StMarie-Thin.otf"
    And I should see "url('../otf/StMarie-Thin.otf"
    And I should see "url('../otf/blank/blank.otf"

  Scenario: Building scss with the feature enabled
    Given a fixture app "fonts-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given a successfully built app at "fonts-app"
    When I cd to "build"
    Then the file "stylesheets/fonts.css" should contain "url('../fonts/StMarie-Thin.otf')"
    And the file "stylesheets/fonts.css" should contain "url('../fonts/blank/blank.otf')"

  Scenario: Building scss with the feature enabled and a custom fonts_dir
    Given a fixture app "fonts-app"
    And a file named "config.rb" with:
      """
      set :fonts_dir, "otf"
      activate :relative_assets
      """
    Given a successfully built app at "fonts-app"
    When I cd to "build"
    Then the file "stylesheets/fonts.css" should not contain "url('../fonts/StMarie-Thin.otf')"
    And the file "stylesheets/fonts.css" should contain "url('../otf/StMarie-Thin.otf')"
    And the file "stylesheets/fonts.css" should contain "url('../otf/blank/blank.otf')"

  Scenario: Relative assets via image_tag
    Given a fixture app "relative-assets-app"
    Given "relative_assets" feature is "enabled"
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag '/img/blank.gif' %>
      """
    And the Server is running at "relative-assets-app"
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="../img/blank.gif" />'

  Scenario: Relative assets should not break data URIs in image_tag
    Given a fixture app "relative-assets-app"
    Given "relative_assets" feature is "enabled"
    And a file named "source/sub/image_tag.html.erb" with:
      """
      <%= image_tag "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" %>
      """
    And the Server is running at "relative-assets-app"
    When I go to "/sub/image_tag.html"
    Then I should see '<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />'