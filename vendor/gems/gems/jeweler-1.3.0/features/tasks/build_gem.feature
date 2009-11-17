Feature: building gems

  Scenario: default
    Given a working directory
    And I use the existing project "existing-project-with-version-yaml" as a template
    And "VERSION.yml" contains hash "{ :major => 1, :minor => 5, :patch => 3}"
    And "existing-project-with-version/pkg/existing-project-with-version-1.5.3.gem" does not exist
    When I run "rake build" in "existing-project-with-version-yaml"
    Then I can gem install "existing-project-with-version-yaml/pkg/existing-project-with-version-1.5.3.gem"
