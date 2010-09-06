Feature: Support Less CSS
 In order to offer an alternative when writing CSS

 Scenario: Rendering Less
   Given the Server is running
   When I go to "/stylesheets/test_less.css"
   Then I should see "666"