Feature: Add an empty alt tag for images that don't have alt tags specified

  Scenario: Image does not have alt tag specified
    Given the Server is running at "default-alt-tags-app"
    When I go to "/empty-alt-tag.html"
    Then I should see 'alt=""'

  Scenario: Image has alt tag specified
    Given the Server is running at "default-alt-tags-app"
    When I go to "/meaningful-alt-tag.html"
    Then I should see 'alt="Meaningful alt text"'
