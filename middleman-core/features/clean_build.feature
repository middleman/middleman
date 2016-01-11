Feature: Build Clean
  Scenario: Build and Clean an app
    Given a fixture app "clean-app"
    And app "clean-app" is using config "empty"
    And a successfully built app at "clean-app" with flags "--no-clean"
    Then the following files should exist:
      | build/index.html              |
      | build/should_be_ignored.html  |
      | build/should_be_ignored2.html |
      | build/should_be_ignored3.html |
    And app "clean-app" is using config "complications"
    Given a successfully built app at "clean-app"
    Then the following files should not exist:
      | build/should_be_ignored.html  |
      | build/should_be_ignored2.html |
      | build/should_be_ignored3.html |
    And the file "build/index.html" should contain "Comment in layout"

  Scenario: Clean build has a whitelist
    Given a fixture app "clean-app"
    When a file named "build/.test" with:
      """
      Hello
      """
    When a file named "config.rb" with:
      """
      set :skip_build_clean do |path|
        path =~ /\.test/
      end
      """
    Given a built app at "clean-app"
    Then the following files should exist:
      | build/.test         |

  Scenario: Clean build an app with newly ignored files and a nested output directory
    Given a fixture app "clean-nested-app"
    When a file named "config.rb" with:
      """
      set :build_dir, "sub/dir"
      """
    Given a built app at "clean-nested-app" with flags "--no-clean"
    Then a directory named "sub/dir" should exist
    Then the following directories should exist:
      | sub/dir                    |
      | sub/dir/nested             |
    Then the following files should exist:
      | sub/dir/about.html         |
      | sub/dir/nested/nested.html |
    When a file named "config.rb" with:
      """
      set :build_dir, "sub/dir"
      ignore 'about.html'
      ignore 'nested/*'
      """
    Given a built app at "clean-nested-app"
    Then the following directories should not exist:
      | sub/dir/nested             |
    Then the following files should not exist:
      | sub/dir/about.html         |
      | sub/dir/nested/nested.html |

  Scenario: Build and clean an app under a hidden directory
    Given a fixture app "clean-app"
    And app "clean-app" is using config "hidden-dir-before"
    And a built app at "clean-app"
    Then the following files should exist:
      | .build/index.html              |
      | .build/should_be_ignored.html  |
      | .build/should_be_ignored2.html |
      | .build/should_be_ignored3.html |
    Given app "clean-app" is using config "hidden-dir-after"
    And a built app at "clean-app"
    Then the following files should exist:
      | .build/index.html              |
    And the following files should not exist:
      | .build/should_be_ignored.html  |
      | .build/should_be_ignored2.html |
      | .build/should_be_ignored3.html |
