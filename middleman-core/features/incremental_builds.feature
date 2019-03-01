
Feature: Incremental builds

  Scenario: Changing a page should only rebuild that page
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "source/standalone.html.erb" with:
      """
      Initial
      """
    When a file named "source/other.html.erb" with:
      """
      Some other file
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    And the file "build/standalone.html" should contain "Initial"
    When a file named "source/standalone.html.erb" with:
      """
      Updated
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "1" files which are updated
    Then the output should contain "updated  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    And the file "build/standalone.html" should contain "Updated"

  Scenario: Changing a layout should only rebuild pages which use that layout
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "source/layout.erb" with:
      """
      Initial
      <%= yield %>
      """
    When a file named "source/page1.html.erb" with:
      """
      Page 1
      """
    When a file named "source/page2.html.erb" with:
      """
      Page 2
      """
    When a file named "source/no-layout.html.erb" with:
      """
      ---
      layout: false
      ---

      Another page
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/page1.html"
    Then the output should contain "create  build/page2.html"
    Then the following files should exist:
      | build/page1.html |
      | build/page2.html |
    And the file "build/page1.html" should contain "Initial"
    And the file "build/page1.html" should contain "Page 1"
    And the file "build/page2.html" should contain "Initial"
    And the file "build/page2.html" should contain "Page 2"
    When a file named "source/layout.erb" with:
      """
      Updated
      <%= yield %>
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "2" files which are updated
    Then the output should contain "updated  build/page1.html"
    Then the output should contain "updated  build/page2.html"
    Then the following files should exist:
      | build/page1.html |
      | build/page2.html |
    And the file "build/page1.html" should contain "Updated"
    And the file "build/page1.html" should contain "Page 1"
    And the file "build/page2.html" should contain "Updated"
    And the file "build/page2.html" should contain "Page 2"

  Scenario: Changing a piece of data only rebuilds the pages which use it
    Given an empty app
    When a file named "config.rb" with:
      """
      data.people.each do |p|
        proxy "/person-#{p.slug}.html", '/person.html', ignore: true, locals: { person: p }
      end
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        name: "Person One"
        age: 5
      -
        slug: "two"
        name: "Person Two"
        age: 10
      """
    When a file named "source/person.html.erb" with:
      """
      <%= person.name %>
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/person-one.html"
    Then the output should contain "create  build/person-two.html"
    Then the following files should exist:
      | build/person-one.html   |
      | build/person-two.html   |
    And the file "build/person-one.html" should contain "Person One"
    And the file "build/person-two.html" should contain "Person Two"
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        name: "Person One"
        age: 15
      -
        slug: "two"
        name: "Person Two"
        age: 20
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are updated
    Then the following files should exist:
      | build/person-one.html   |
      | build/person-two.html   |
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        name: "Person One"
        age: 5
      -
        slug: "two"
        name: "Person Updated"
        age: 10
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "1" files which are updated
    Then the output should contain "updated  build/person-two.html"
    Then the following files should exist:
      | build/person-one.html   |
      | build/person-two.html   |
    And the file "build/person-two.html" should contain "Person Updated"
    When a file named "data/people.yml" with:
      """
      -
        slug: "updated-slug"
        name: "Person New Slug"
        age: 5
      -
        slug: "two"
        name: "Person Updated"
        age: 10
      """
    Then build app with only changed
    Then there are "1" files which are created
    Then there are "1" files which are removed
    Then there are "0" files which are updated
    Then the output should contain "create  build/person-updated-slug.html"
    Then the output should contain "remove  build/person-one.html"
    Then the following files should exist:
      | build/person-updated-slug.html |
      | build/person-two.html   |
    And the file "build/person-updated-slug.html" should contain "Person New Slug"

  Scenario: Accessing a method which can't wrap data indexes (to_json) will rebuild on change to the entire object
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "data/people.yml" with:
      """
      -
        name: "Person One"
      -
        name: "Person Two"
      """
    When a file named "source/people.json.erb" with:
      """
      <%= data.people.to_json %>
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/people.json"
    Then the following files should exist:
      | build/people.json |
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    When a file named "data/people.yml" with:
      """
      -
        name: "Person One"
      -
        name: "Person Two Updated"
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "1" files which are updated
    When a file named "data/people.yml" with:
      """
      -
        name: "Person One Updated"
      -
        name: "Person Two Updated"
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "1" files which are updated

  Scenario: Accessing a method which can't wrap data indexes (size) will rebuild on change to the entire objecty (nested)
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "data/person.yml" with:
      """
      name: "Person One"
      items:
        - 1
        - 2
      """
    When a file named "source/items.html.erb" with:
      """
      <%= data.person.items.size %>
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/items.html"
    Then the following files should exist:
      | build/items.html |
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    Then there are "0" files which are identical
    When a file named "data/person.yml" with:
      """
      name: "Person One"
      items:
        - 1
        - 2
        - 3
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "1" files which are updated
    Then there are "0" files which are identical
    When a file named "data/person.yml" with:
      """
      name: "Person One"
      items:
        - 4
        - 2
        - 3
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    Then there are "1" files which are identical

  Scenario: Updating a partial should only update templates which include it
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "source/page-a.html.erb" with:
      """
      <%= partial :test %>
      """
    When a file named "source/page-b.html.erb" with:
      """
      <%= partial :test %>
      """
    When a file named "source/_test.erb" with:
      """
      I am the partial
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/bait.html"
    Then the output should contain "create  build/page-a.html"
    Then the output should contain "create  build/page-b.html"
    Then the following files should exist:
      | build/bait.html |
      | build/page-a.html |
      | build/page-b.html |
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    When a file named "source/_test.erb" with:
      """
      Updated partial
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "2" files which are updated

  Scenario: Updating a nested partial should only update templates which include it
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.html.erb" with:
      """
      ---
      layout: false
      ---

      Bait
      """
    When a file named "source/page-a.html.erb" with:
      """
      <%= partial :test %>
      """
    When a file named "source/page-b.html.erb" with:
      """
      <%= partial :test %>
      """
    When a file named "source/_test.erb" with:
      """
      <%= partial :other %>
      """
    When a file named "source/_other.erb" with:
      """
      I am the partial
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/bait.html"
    Then the output should contain "create  build/page-a.html"
    Then the output should contain "create  build/page-b.html"
    Then the following files should exist:
      | build/bait.html |
      | build/page-a.html |
      | build/page-b.html |
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    When a file named "source/_other.erb" with:
      """
      Updated partial
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "2" files which are updated

  Scenario: Updating a sass import should only update files which include it
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "source/bait.css.scss" with:
      """
      body { h1 { color: red } }
      """
    When a file named "source/css-a.css.scss" with:
      """
      @import 'test';
      """
    When a file named "source/css-b.css.scss" with:
      """
      @import 'test';
      """
    When a file named "source/_test.scss" with:
      """
      h1 { bold { text-decoration: underline } }
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/bait.css"
    Then the output should contain "create  build/css-a.css"
    Then the output should contain "create  build/css-b.css"
    Then the following files should exist:
      | build/bait.css |
      | build/css-a.css |
      | build/css-b.css |
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    When a file named "source/_test.scss" with:
      """
      h1 { bold { text-decoration: none } }
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "2" files which are updated

  Scenario: Should ignore vendored dependencies
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "vendor/dep.rb" with:
      """
      """
    When a file named "source/index.html.erb" with:
      """
      Hello
      """
    Then build the app tracking dependencies
    Then the file "deps.yml" should not contain "file: vendor/"

  Scenario: Changing a piece of data nested below the maximum depth will rebuild on change to the entire object
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        parts:
          - 1
          - 2
          - 3
      -
        slug: "two"
        parts:
          - 4
          - 5
          - 6
      """
    When a file named "source/part-one.html.erb" with:
      """
      Part = <%= data.people.last.parts.first %>
      """
    When a file named "source/part-two.html.erb" with:
      """
      Part = <%= data.people.last.parts[1] %>
      """
    Then build the app tracking dependencies
    Then the output should contain "create  build/part-one.html"
    Then the output should contain "create  build/part-two.html"
    Then the following files should exist:
      | build/part-one.html   |
      | build/part-two.html   |
    And the file "build/part-one.html" should contain "Part = 4"
    And the file "build/part-two.html" should contain "Part = 5"
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        parts:
          - 1
          - 2
          - 3
      -
        slug: "two"
        parts:
          - 4
          - 5
          - 7
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are updated
    Then the following files should exist:
      | build/part-one.html   |
      | build/part-two.html   |
    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        parts:
          - 1
          - 2
          - 3
      -
        slug: "two"
        parts:
          - 4
          - 6
          - 7
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "1" files which are updated
    Then the output should contain "updated  build/part-two.html"
    Then the following files should exist:
      | build/part-one.html   |
      | build/part-two.html   |
    And the file "build/part-two.html" should contain "Part = 6"

    # Rebuilding with limited depth
    Then build the app tracking dependencies with depth "1"

    When a file named "data/people.yml" with:
      """
      -
        slug: "one"
        parts:
          - 1
          - 2
          - 3
      -
        slug: "two"
        parts:
          - 4
          - 6
          - 8
      """
    Then build app with only changed
    Then there are "0" files which are created
    Then there are "0" files which are removed
    Then there are "0" files which are updated
    Then there are "2" files which are identical
    Then the output should contain "identical  build/part-one.html"
    Then the output should contain "identical  build/part-two.html"
    Then the following files should exist:
      | build/part-one.html |
      | build/part-two.html |
    And the file "build/part-one.html" should contain "Part = 4"
    And the file "build/part-two.html" should contain "Part = 6"

  Scenario: Wrapped collection methods, like `select`, should effect downstream methods.
    Given an empty app
    When a file named "config.rb" with:
      """
      """
    When a file named "data/roles.yml" with:
      """
      - title: "Job"
        salary: 1111
      """
    When a file named "source/roles/data.json.erb" with:
      """
      {
        "roles": <%= data.roles.select(&:salary).to_json %>,
        "roles2": <%= data.roles.first.as_json %>
      }
      """
    Then build the app tracking dependencies with depth "1"
    Then there are "1" files which are created