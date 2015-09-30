Feature: Allow nesting of layouts

  Scenario: A page uses an inner layout when uses an outer layout
    Given the Server is running at "nested-layout-app"
    When I go to "/index.html"
    Then I should see:
    """
    Master
    <h1>Index Title</h1>
      Outer
        Inner
      Template
    
    """
    When I go to "/another.html"
    Then I should see:
    """
    Master
    <h1>New Article Title</h1>
      Outer
        Inner
      <p>The Article Content</p>
    """
    
  Scenario: A page uses an inner layout when uses an outer layout (slim)
    Given the Server is running at "nested-layout-app"
    When I go to "/slim-test.html"
    Then I should see "<h1>Master</h1><p>New Article Title</p><div><h2>Outer</h2><h3>Inner</h3><p>The Article Content</p>"
    
  Scenario: A page uses an inner layout when uses an outer layout (haml)
    Given the Server is running at "nested-layout-app"
    When I go to "/haml-test.html"
    Then I should see:
    """
    Master
    <h1>New Article Title</h1>
    Outer
    Inner
    <p>The Article Content</p>
    """

  Scenario: YAML Front Matter isn't clobbered with nested layouts
    Given the Server is running at "nested-layout-app"
    When I go to "/data-one.html"
    Then I should see "Page Number One"
    And I should see "Inner"
    When I go to "/data-two.html"
    Then I should see "Page Number Two"
    And I should not see "Inner"
    When I go to "/data-one.html"
    Then I should see "Page Number One"
    And I should see "Inner"
    When I go to "/data-two.html"
    Then I should see "Page Number Two"
    And I should not see "Inner"
