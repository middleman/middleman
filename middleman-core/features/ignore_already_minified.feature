Feature: CSS and Javascripts which are minify shouldn't be re-minified

  Scenario: JS files containing ".min" should not be re-compressed
    Given an empty app
    And a file named "config.rb" with:
      """
      activate :minify_javascript
      """
    And a file named "source/javascripts/test.min.js" with:
      """
      var numbers = [ 1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10 ];
      """
    And the Server is running at "empty_app"
    When I go to "/javascripts/test.min.js"
    Then I should see "10" lines
    
  Scenario: CSS files containing ".min" should not be re-compressed
    Given an empty app
    And a file named "config.rb" with:
      """
      activate :minify_css
      """
    And a file named "source/stylesheets/test.min.css" with:
      """
      body { one: 1;
        two: 2;
        three: 3;
        four: 4;
        five: 5;
        six: 6;
        seven: 7;
        eight: 8;
        nine: 9; 
        ten: 10; }
      """
    And the Server is running at "empty_app"
    When I go to "/stylesheets/test.min.css"
    Then I should see "10" lines