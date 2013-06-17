Feature: v3 Modular Extension
  Scenario: Registering and overwriting a system config option
    Given a fixture app "large-build-app"
    And a file named "config.rb" with:
      """
      module MyFeature
        class << self
          def registered(app)
            app.set :css_dir, "lib/my/css"
          end
          alias :included :registered
        end
      end

      ::Middleman::Extensions.register(:my_feature, MyFeature)
      activate :my_feature
      """
    Given a successfully built app at "large-build-app"
    When I cd to "build"
    Then the file "link_test.html" should contain "lib/my/css/test.css"