Feature: Allow content with multiple sources to reload
  Scenario: With source that does not specify a destination directory
    Given the Server is running at "multiple-sources-without-destination-dir"
    When I go to "/page.html"
    Then I should see "Before edit"

    When the file "external/page.html.erb" has the contents
      """
      After edit
      """
    And I go to "/page.html"
    Then I should see "After edit"


  Scenario: With source that specifies destination directory
    Given the Server is running at "multiple-sources-with-destination-dir"
    When I go to "/external/page.html"
    Then I should see "Before edit"

    When the file "external/page.html.erb" has the contents
      """
      After edit
      """
    And I go to "/external/page.html"
    Then I should see "After edit"

  Scenario: With external source and a destination directory name different from source directory name
    Given a fixture app "destination-dir-different-from-source-dir-name"
    And I cd to "my-app"
    And the Server is running

    When I go to "/my_dir/page.html"
    Then I should see "Before edit"

    When the file "../external/page.html.erb" has the contents
      """
      After edit
      """
    And I go to "/my_dir/page.html"
    Then I should see "After edit"
