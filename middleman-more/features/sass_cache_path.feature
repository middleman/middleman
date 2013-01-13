Feature: SASS .sass-cache custom location

  Scenario: Using the default location for .sass-cache folder
    Given the Server is running at "sass-cache-path-default-app"

    When I go to "/stylesheets/plain.css"
    Then I should see "color: blue;"

    #  TODO:: 
    #  Not sure how to test this location, as the directory is stored outside of the app root
    #  during testing, but inside app root in "production"

    # Then a directory named ".sass-cache" should exist


  Scenario: Using a custom location for .sass-cache folder
    Given the Server is running at "sass-cache-path-custom-app"

    When I go to "/stylesheets/plain.css"
    Then I should see "html, body, div, span, applet, object, iframe,"

    Then a directory named "/tmp/middleman-more-custom-sass_cache_path" should exist
