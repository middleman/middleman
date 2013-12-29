Feature: select_tag helper

  Scenario: select_tag produces correct options
    Given a fixture app "indexable-app"
    And an empty file named "config.rb"
    And a file named "source/select_tag.html.erb" with:
    """
    options as array: <%= select_tag :colors, options: ["red", "blue", "blorange"], include_blank: "Choose a color" %>
    """
    And the Server is running at "indexable-app"
    When I go to "/select_tag.html"
    Then I should see:
    """
    <select name="colors"><option value="">Choose a color</option>
    <option value="red">red</option>
    <option value="blue">blue</option>
    <option value="blorange">blorange</option>
    </select>
    """
