Feature: version rake task

  #Scenario: a newly created project without a version
  #  Given a working directory
  #  And I use the jeweler command to generate the "the-perfect-gem" project in the working directory
  #  And "the-perfect-gem/VERSION" does not exist
  #  When I run "rake version" in "the-perfect-gem"
  #  Then the process should not exit cleanly

  Scenario: an existing project with version yaml
    Given a working directory
    And I use the existing project "existing-project-with-version-yaml" as a template
    And "VERSION.yml" contains hash "{ :major => 1, :minor => 5, :patch => 3}"
    When I run "rake version" in "existing-project-with-version-yaml"
    Then the process should exit cleanly
    And the current version, 1.5.3, is displayed

  Scenario: an existing project with version plaintext
    Given a working directory
    And I use the existing project "existing-project-with-version-plaintext" as a template
    And "VERSION" contains "1.5.3"
    When I run "rake version" in "existing-project-with-version-plaintext"
    Then the process should exit cleanly
    And the current version, 1.5.3, is displayed

  Scenario: an existing project with version constant
    Given a working directory
    And I use the existing project "existing-project-with-version-constant" as a template
    When I run "rake version" in "existing-project-with-version-constant"
    Then the process should exit cleanly
    And the current version, 1.0.0, is displayed
