Feature: Support Rack apps mounted using map

  Scenario: Mounted Rack App at /sinatra
    Given the Server is running at "sinatra-app"
    When I go to "/"
    Then I should see "Hello World (Middleman)"
    When I go to "/sinatra/"
    Then I should see "Hello World (Sinatra)"

  Scenario: Built Mounted Rack App at /sinatra
    Given a successfully built app at "sinatra-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
    Then the following files should not exist:
      | sinatra/index.html |
      | sinatra/index2.html |

  Scenario: Static Ruby Endpoints
    Given a fixture app "sinatra-app"
    And a file named "config.rb" with:
    """
    endpoint "hello.html" do
      "world"
    end
    """
    And the Server is running at "sinatra-app"
    When I go to "/hello.html"
    Then I should see "world"

  Scenario: Built Mounted Rack App at /sinatra (including rack endpoints)
    Given a fixture app "sinatra-app"
    And a file named "config.rb" with:
      """
      require "sinatra"

      class MySinatra < Sinatra::Base
        get "/" do
          "Hello World (Sinatra)"
        end
        get "/derp.html" do
          "De doo"
        end
      end

      map "/sinatra" do
        run MySinatra
      end

      endpoint "sinatra/index2.html", path: "/sinatra/"

      endpoint "dedoo.html", path: "/sinatra/derp.html"

      endpoint "hello.html" do
        "world"
      end
      """
    And a successfully built app at "sinatra-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | sinatra/index2.html |
      | dedoo.html |
    And the file "sinatra/index2.html" should contain 'Hello World (Sinatra)'
    And the file "dedoo.html" should contain 'De doo'