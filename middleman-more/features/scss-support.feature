Feature: Support SCSS Syntax
 In order to offer an alternative when writing Sass

 Scenario: Rendering scss
   Given the Server is running at "scss-app"
   When I go to "/stylesheets/site_scss.css"
   Then I should see "html"

 Scenario: Rendering scss
   Given the Server is running at "scss-app"
   When I go to "/stylesheets/layout.css"
   Then I should see "html"