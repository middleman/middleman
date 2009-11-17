Feature: custom example group

  Scenario: simple custom example group
    Given a file named "custom_example_group_spec.rb" with:
      """
      class CustomGroup < Spec::ExampleGroup
      end

      Spec::Example::ExampleGroupFactory.default(CustomGroup)

      describe "a custom group set as the default" do
        it "becomes the default base class for example groups" do
          CustomGroup.should === self
        end
      end
      """
    When I run "spec custom_example_group_spec.rb"
    Then the stdout should include "1 example, 0 failures"

