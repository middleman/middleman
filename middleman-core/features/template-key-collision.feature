Feature: Don't allow template locals to overwrite template helpers

  Scenario: Normal Template
    Given an empty app
    And a file named "config.rb" with:
      """
      class TestExt < ::Middleman::Extension
        expose_to_template foo: :foo

        def foo
          "bar"
        end
      end

      ::Middleman::Extensions.register :test, TestExt

      activate :test

      page "/index.html", locals: { foo: false }
      """
    And a file named "source/index.html.erb" with:
      """
      <%= foo %>
      """
    Given a built app at "empty_app"
    Then the exit status should be 1
