Feature: Step through sitemap as a tree

  Scenario: Root
    Given the Server is running at "traversal-app"
    When I go to "/index.html"
    Then I should see "Path: index.html"
    Then I should not see "Parent: index.html"
    Then I should see "Child: sub/index.html"
    Then I should see "Child: root.html"
    Then I should not see "Child: proxied.html"
  
  Scenario: Directories have children and a parent
    Given the Server is running at "traversal-app"
    When I go to "/sub/index.html"
    Then I should see "Path: sub/index.html"
    Then I should see "Parent: index.html"
    Then I should see "Child: sub/fake.html"
    Then I should see "Child: sub/fake2.html"
    Then I should see "Child: sub/sibling.html"
    Then I should see "Child: sub/sibling2.html"
    Then I should see "Child: sub/sub2/index.html"
    Then I should see "Sibling: root.html"

  Scenario: Directory accessed without index.html
    Given the Server is running at "traversal-app"
    When I go to "/sub/"
    Then I should see "Path: sub/index.html"
    Then I should see "Parent: index.html"
    Then I should see "Child: sub/fake.html"
    Then I should see "Child: sub/fake2.html"
    Then I should see "Child: sub/sibling.html"
    Then I should see "Child: sub/sibling2.html"
    Then I should see "Child: sub/sub2/index.html"
    Then I should see "Sibling: root.html"
    
  Scenario: Page has siblings, parent, and source file
    Given the Server is running at "traversal-app"
    When I go to "/sub/sibling/"
    Then I should see "Parent: sub/index.html"
    Then I should see "Sibling: sub/fake.html"
    Then I should see "Sibling: sub/fake2.html"
    Then I should see "Sibling: sub/sibling2.html"
    Then I should see "Sibling: sub/sub2/index.html"
    Then I should see "Source: source/sub/sibling.html.erb"
  
  Scenario: Proxied page has siblings, parent, and source file
    Given the Server is running at "traversal-app"
    When I go to "/sub/fake/"
    Then I should see "Path: sub/fake.html"
    Then I should see "Parent: sub/index.html"
    Then I should see "Sibling: sub/fake2.html"
    Then I should see "Sibling: sub/sibling.html"
    Then I should see "Sibling: sub/sibling2.html"
    Then I should see "Sibling: sub/sub2/index.html"
    Then I should see "Source: source/proxied.html.erb"

  Scenario: Child pages have data
    Given the Server is running at "traversal-app"
    When I go to "/directory-indexed"
    Then I should see "Title of Sibling One"
    Then I should see "Title of Sibling Two"

  Scenario: When directory_index extension is active, child pages are found in named directory
    Given the Server is running at "traversal-app"
    When I go to "/directory-indexed"
    Then I should see "Path: directory-indexed.html"
    Then I should see "Parent: index.html"
    Then I should see "Child: directory-indexed/fake.html"
    Then I should see "Child: directory-indexed/fake2.html"
    Then I should see "Child: directory-indexed/sibling.html"
    Then I should see "Child: directory-indexed/sibling2.html"
    Then I should see "Child: directory-indexed/sub2/index.html"
    Then I should see "Sibling: root.html"
