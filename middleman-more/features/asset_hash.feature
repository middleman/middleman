Feature: Assets get a file hash appended to their and references to them are updated
  Scenario: Hashed-asset files are produced, and HTML, CSS, and JavaScript gets rewritten to reference the new files
    Given a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | images/100px-1242c368.png |
      | images/100px-5fd6fb90.jpg |
      | images/100px-5fd6fb90.gif |
      | javascripts/application-1d8d5276.js |
      | stylesheets/site-92072d15.css |
      | index.html |
      | subdir/index.html |
      | other/index.html |
    And the following files should not exist:
      | images/100px.png |
      | images/100px.jpg |
      | images/100px.gif |
      | javascripts/application.js |
      | stylesheets/site.css |
      
    And the file "javascripts/application-1d8d5276.js" should contain "img.src = '/images/100px-5fd6fb90.jpg'"
    # TODO: This stylesheet should use the SASS "image-url" helper but can't because of https://github.com/middleman/middleman/issues/283
    And the file "stylesheets/site-92072d15.css" should contain 'background-image: url("/images/100px-5fd6fb90.jpg")'
    And the file "index.html" should contain 'link href="stylesheets/site-92072d15.css"'
    And the file "index.html" should contain 'script src="javascripts/application-1d8d5276.js"'
    And the file "index.html" should contain 'img src="images/100px-5fd6fb90.jpg"'
    And the file "subdir/index.html" should contain 'link href="../stylesheets/site-92072d15.css"'
    And the file "subdir/index.html" should contain 'script src="../javascripts/application-1d8d5276.js"'
    And the file "subdir/index.html" should contain 'img src="../images/100px-5fd6fb90.jpg"'
    And the file "other/index.html" should contain 'link href="../stylesheets/site-92072d15.css"'
    And the file "other/index.html" should contain 'script src="../javascripts/application-1d8d5276.js"'
    And the file "other/index.html" should contain 'img src="../images/100px-5fd6fb90.jpg"'
    
  Scenario: Hashed assets work in preview server
    Given the Server is running at "asset-hash-app"
    When I go to "/"
    Then I should see 'link href="stylesheets/site-92072d15.css"'
    And I should see 'script src="javascripts/application-1d8d5276.js"'
    And I should see 'img src="images/100px-5fd6fb90.jpg"'
    When I go to "/subdir/"
    Then I should see 'link href="../stylesheets/site-92072d15.css"'
    And I should see 'script src="../javascripts/application-1d8d5276.js"'
    And I should see 'img src="../images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'link href="../stylesheets/site-92072d15.css"'
    And I should see 'script src="../javascripts/application-1d8d5276.js"'
    And I should see 'img src="../images/100px-5fd6fb90.jpg"'
    When I go to "/javascripts/application-1d8d5276.js"
    Then I should see "img.src = '/images/100px-5fd6fb90.jpg'"
    When I go to "/stylesheets/site-92072d15.css"
    Then I should see 'background-image: url("/images/100px-5fd6fb90.jpg")'

  Scenario: Enabling an asset host still produces hashed files and references

