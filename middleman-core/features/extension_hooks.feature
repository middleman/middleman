Feature: Extension author could use some hooks

  Scenario: When build
    Given a successfully built app at "extension-hooks-app"
    And the output should contain "/// after_configuration ///"
    And the output should contain "/// ready ///"
    And the output should contain "/// before_build ///"
    And the output should contain "/// before ///"
    And the output should contain "/// before_render ///"
    And the output should contain "/// after_render ///"
    And the output should contain "/// after_build ///"
