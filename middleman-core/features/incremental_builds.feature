Feature: Incremental builds

  Scenario: Changing a page should only rebuild that page
    Given an empty app
    When a file named "config.rb" with:
      """
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
    Then was successfully built
    Then the output should contain "create  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    And the file "build/standalone.html" should contain "Initial"
    When a file named "source/standalone.html.erb" with:
      """
      Updated
      """
    Then build app with only changed
    Then was successfully built
    Then there are "0" files which are "      create  "
    Then there are "1" files which are "     updated  "
    Then the output should contain "updated  build/standalone.html"
    Then the following files should exist:
      | build/standalone.html |
    And the file "build/standalone.html" should contain "Updated"

  Scenario: Changing a layout should only rebuild pages which use that layout
    Given an empty app
    When a file named "config.rb" with:
      """
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
    Then was successfully built
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
    Then was successfully built
    Then there are "0" files which are "      create  "
    Then there are "2" files which are "     updated  "
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
    Then was successfully built
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
    Then was successfully built
    Then there are "0" files which are "      create  "
    Then there are "0" files which are "     updated  "
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
    Then was successfully built
    Then there are "0" files which are "      create  "
    Then there are "1" files which are "     updated  "
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
    Then was successfully built
    Then there are "1" files which are "      create  "
    Then there are "1" files which are "      remove  "
    Then there are "0" files which are "     updated  "
    Then the output should contain "create  build/person-updated-slug.html"
    Then the output should contain "remove  build/person-one.html"
    Then the following files should exist:
      | build/person-updated-slug.html |
      | build/person-two.html   |
    And the file "build/person-updated-slug.html" should contain "Person New Slug"