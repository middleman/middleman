Feature: Layouts dir
  Scenario: Find layouts in a custom layouts dir
    Given a fixture app "layouts-dir-app"
    And a file named "config.rb" with:
    """
    set :layouts_dir, 'layouts2'
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the custom layout"

  Scenario: Find layouts in a nested custom layouts dir
    Given a fixture app "layouts-dir-app"
    And a file named "config.rb" with:
    """
    set :layouts_dir, 'nested/layouts2'
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the nested layout"

  Scenario: Find layouts in the default layouts dir
    Given a fixture app "layouts-dir-app"
    And a file named "config.rb" with:
    """
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see "contents of the layout"

  Scenario: Prefer a layout in the layouts_dir to one with the same name in the root
    Given a fixture app "layouts-dir-app"
    And a file named "config.rb" with:
    """
    """
    And the Server is running
    When I go to "/ambiguous.html"
    Then I should see "contents of the layout in layouts_dir"
