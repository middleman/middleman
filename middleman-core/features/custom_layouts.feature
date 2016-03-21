Feature: Custom layouts
  In order easily switch between relative and absolute paths

  Scenario: Using custom :layout attribute
    Given a fixture app "custom-layout-app2"
    And a file named "config.rb" with:
      """
      page '/custom-layout.html', layout: :custom
      """
    And the Server is running at "custom-layout-app2"
    When I go to "/custom-layout.html"
    Then I should see "Custom Layout"

  Scenario: Using custom :layout attribute with proxy
    Given a fixture app "custom-layout-app2"
    And a file named "config.rb" with:
      """
      page '/test/*', layout: :custom
      proxy "/test/me.html", "/custom-layout.html"
      live { %w(you) }.each do |who|
        proxy "/test/#{who}.html", "/custom-layout.html"
      end
      """
    And the Server is running at "custom-layout-app2"
    When I go to "/test/me.html"
    Then I should see "Custom Layout"
    When I go to "/test/you.html"
    Then I should see "Custom Layout"

  Scenario: Using custom :layout attribute with folders
    Given a fixture app "custom-layout-app2"
    And a file named "config.rb" with:
      """
      page '/custom-layout-dir/', layout: :custom
      """
    And the Server is running at "custom-layout-app2"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"

  Scenario: Using custom :layout attribute with folders
    Given a fixture app "custom-layout-app2"
    And a file named "config.rb" with:
      """
      page '/custom-layout-dir', layout: :custom
      """
    And the Server is running at "custom-layout-app2"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"

  Scenario: Using custom :layout attribute with folders
    Given a fixture app "custom-layout-app2"
    And a file named "config.rb" with:
      """
      page '/custom-layout-dir/index.html', layout: :custom
      """
    And the Server is running at "custom-layout-app2"
    When I go to "/custom-layout-dir"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/"
    Then I should see "Custom Layout"
    When I go to "/custom-layout-dir/index.html"
    Then I should see "Custom Layout"

  Scenario: Setting layout inside a matching page block
    Given the Server is running at "page-helper-layout-block-app"
    When I go to "/index.html"
    Then I should see "Hello"
    And I should see "World"
    When I go to "/path/child.html"
    Then I should see "Alt"
    And I should see "Child"
    And I should not see "Hello"
    When I go to "/path/index.html"
    Then I should see "Alt"
    And I should see "Monde"
    And I should not see "Hello"
