Feature: Support SASS assets paths
 In order to import common shared assets when writing Sass

 Scenario: Importing assets from 'assets/stylesheets/' directory in app root
   Given the Server is running at "sass-assets-path-app"
   When I go to "/stylesheets/plain.css"
   Then I should see "color: green;"
   Then I should see "/* Works with shared SCSS assets from APPROOT/assets/stylesheets/_shared-asset.scss */"
   Then I should see "/* Works with shared SASS assets from APPROOT/assets/stylesheets/_shared-asset-sass.sass */"
   Then I should see "font-size: 18px"
   Then I should see "/* Works with shared SASS assets from external source directory */"
