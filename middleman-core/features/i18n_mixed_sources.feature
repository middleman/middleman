Feature: i18n merging path trees

  Scenario: Mixing localized and non-localized sources and merging the path trees (see issue #1709)
    Given the Server is running at "i18n-mixed-sources"

    When I go to "/"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home"
    When I go to "/es"
    Then I should see "Current locale: es"
    Then I should see "path: is-localized Home"

    When I go to "/a/"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home # a/index.html.erb"
    When I go to "/es/a/"
    Then I should see "Current locale: es"
    Then I should see "path: is-localized Home # a/index.html.erb"

    When I go to "/b/"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home # b/index.html.erb"

    When I go to "/a/sub.html"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home # a/index.html.erb # a/sub.html.erb"

    When I go to "/b/sub.html"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home # b/index.html.erb # b/sub.html.erb"

    When I go to "/es/b/sub.html"
    Then I should see "Current locale: es"
    Then I should see "path: is-localized Home # b/index.html.erb # b/sub.html.erb"

    When I go to "/c/d/index.html"
    Then I should see "Current locale: en"
    Then I should see "path: is-localized Home # c/d/index.html.erb"

    When I go to "/es/c/d/index.html"
    Then I should see "Current locale: es"
    Then I should see "path: is-localized Home # c/d/index.html.erb"
