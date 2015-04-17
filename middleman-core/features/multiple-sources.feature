Feature: Allow multiple sources to be setup.

  Scenario: Three source directories.
    Given the Server is running at "multiple-sources-app"
    When I go to "/index.html"
    Then I should see "Default Source"

    When I go to "/index1.html"
    Then I should see "Source 1"

    When I go to "/index2.html"
    Then I should see "Source 2"

    When I go to "/override-in-two.html"
    Then I should see "Overridden 2"

    When I go to "/override-in-one.html"
    Then I should see "Opposite 2"

  Scenario: Three data directories.
    Given the Server is running at "multiple-data-sources-app"
    When I go to "/index.html"
    Then I should see "Default: Data Default"
    Then I should see "Data 1: Data 1"
    Then I should see "Data 2: Data 2"
    Then I should see "Override in Two: Overridden 2"
    Then I should see "Override in One: Opposite 2"

  Scenario: Set source with destination_dir
    Given the Server is running at "multiple-sources-with-duplicate-file-names-app"
    When I go to "/index.html"
    Then I should see "Default Source"

    When I go to "/source2/index.html"
    Then I should see "Second Source"
