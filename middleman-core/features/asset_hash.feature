Feature: Assets get a file hash appended to their and references to them are updated
  Scenario: Hashed-asset files are produced, and HTML, CSS, JSON and JavaScript gets rewritten to reference the new files
    Given a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | apple-touch-icon.png |
      | favicon.ico |
      | images/100px-1242c368.png |
      | images/100px-5fd6fb90.jpg |
      | images/200px-c11eb203.jpg |
      | images/300px-59adce76.jpg |
      | images/100px-5fd6fb90.gif |
      | javascripts/application-1d8d5276.js |
      | stylesheets/site-50eaa978.css |
      | index.html |
      | subdir/index.html |
      | other/index.html |
      | api.json |
      | subdir/api.json |
    And the following files should not exist:
      | images/100px.png |
      | images/100px.jpg |
      | images/100px.gif |
      | javascripts/application.js |
      | stylesheets/site.css |

    And the file "javascripts/application-1d8d5276.js" should contain "img.src = '/images/100px-5fd6fb90.jpg'"
    And the file "stylesheets/site-50eaa978.css" should contain "background-image: url('../images/100px-5fd6fb90.jpg')"
    And the file "index.html" should contain 'href="apple-touch-icon.png"'
    And the file "index.html" should contain 'href="stylesheets/site-50eaa978.css"'
    And the file "index.html" should contain 'src="javascripts/application-1d8d5276.js"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.jpg"'
    And the file "index.html" should contain 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.gif"'
    And the file "index.html" should contain 'src="images/100px-1242c368.png"'
    And the file "subdir/index.html" should contain 'href="../stylesheets/site-50eaa978.css"'
    And the file "subdir/index.html" should contain 'src="../javascripts/application-1d8d5276.js"'
    And the file "subdir/index.html" should contain 'src="../images/100px-5fd6fb90.jpg"'
    And the file "other/index.html" should contain 'href="../stylesheets/site-50eaa978.css"'
    And the file "other/index.html" should contain 'src="../javascripts/application-1d8d5276.js"'
    And the file "other/index.html" should contain 'src="../images/100px-5fd6fb90.jpg"'
    And the file "api.json" should contain 'images/100px-5fd6fb90.gif'
    And the file "api.json" should contain 'images/100px-5fd6fb90.jpg'
    And the file "api.json" should contain 'images/100px-1242c368.png'
    And the file "subdir/api.json" should contain 'images/100px-5fd6fb90.gif'
    And the file "subdir/api.json" should contain 'images/100px-5fd6fb90.jpg'
    And the file "subdir/api.json" should contain 'images/100px-1242c368.png'

  Scenario: Hashed fonts assets work with woff and woff2 extension
    Given a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | fonts/fontawesome-webfont-56ce13e7.woff |
      | fonts/fontawesome-webfont-10752316.woff2 |
    And the file "stylesheets/uses_fonts-88aa3e2b.css" should contain "src: url('../fonts/fontawesome-webfont-10752316.woff2')"
    And the file "stylesheets/uses_fonts-88aa3e2b.css" should contain "url('../fonts/fontawesome-webfont-56ce13e7.woff')"

  Scenario: Hashed assets work in preview server
    Given the Server is running at "asset-hash-app"
    When I go to "/"
    Then I should see 'href="apple-touch-icon.png"'
    And I should see 'href="stylesheets/site-50eaa978.css"'
    And I should see 'src="javascripts/application-1d8d5276.js"'
    And I should see 'src="images/100px-5fd6fb90.jpg"'
    And I should see 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'
    When I go to "/subdir/"
    Then I should see 'href="../stylesheets/site-50eaa978.css"'
    And I should see 'src="../javascripts/application-1d8d5276.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="../stylesheets/site-50eaa978.css"'
    And I should see 'src="../javascripts/application-1d8d5276.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    When I go to "/javascripts/application-1d8d5276.js"
    Then I should see "img.src = '/images/100px-5fd6fb90.jpg'"
    When I go to "/stylesheets/site-50eaa978.css"
    Then I should see "background-image: url('../images/100px-5fd6fb90.jpg')"
    When I go to "/api.json"
    Then I should see 'images/100px-5fd6fb90.gif'
    And I should see 'images/100px-5fd6fb90.jpg'
    And I should see 'images/100px-1242c368.png'
    When I go to "/subdir/api.json"
    Then I should see 'images/100px-5fd6fb90.gif'
    And I should see 'images/100px-5fd6fb90.jpg'
    And I should see 'images/100px-1242c368.png'

  Scenario: Hashed assets work with Slim
    Given the Server is running at "asset-hash-app"
    When I go to "/slim.html"
    And I should see 'src="images/300px-59adce76.jpg"'
    And I should see 'src="images/100px-5fd6fb90.jpg"'
    And I should see 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'

  Scenario: Enabling an asset host still produces hashed files and references
    Given the Server is running at "asset-hash-host-app"
    When I go to "/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-54baaf3a.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/subdir/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-54baaf3a.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-54baaf3a.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    # Asset helpers don't appear to work from Compass right now
    # When I go to "/stylesheets/site-e5a31a3e.css"
    # Then I should see "background-image: url('http://middlemanapp.com/images/100px-5fd6fb90.jpg')"

  Scenario: The asset hash should change when a SASS partial changes
    Given the Server is running at "asset-hash-app"
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-423a00f7.css'
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 18px !important
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-e8c3d4eb.css'

  Scenario: The asset hash should change when a Rack-based filter changes
    Given a fixture app "asset-hash-app"
    And a file named "config.rb" with:
      """
      activate :asset_hash
      activate :relative_assets
      activate :directory_indexes
      require 'lib/middleware.rb'
      use Middleware
      """
    Given the Server is running at "asset-hash-app"
    When I go to "/"
    Then I should see 'href="stylesheets/site-5770af52.css'
    When I go to "stylesheets/site-5770af52.css"
    Then I should see 'background-image'
    Then I should see 'Added by Rack filter'
    When I go to "stylesheets/site-50eaa978.css"
    Then I should see 'Not Found'

  Scenario: Hashed-asset files are not produced for ignored paths
    Given a fixture app "asset-hash-app"
    And a file named "config.rb" with:
      """
      activate :asset_hash, :ignore => [%r(javascripts/*), 'images/*']
      activate :relative_assets
      activate :directory_indexes
      """
    And a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | apple-touch-icon.png |
      | favicon.ico |
      | images/100px.png |
      | images/100px.jpg |
      | images/100px.gif |
      | javascripts/application.js |
      | stylesheets/site-50eaa978.css |
      | index.html |
      | subdir/index.html |
      | other/index.html |
      | api.json |
      | subdir/api.json |
    And the following files should not exist:
      | images/100px-1242c368.png |
      | images/100px-5fd6fb90.jpg |
      | images/100px-5fd6fb90.gif |
      | javascripts/application-1d8d5276.js |
      | stylesheets/site.css |

  # @wip Currently broken, we should move all asset-host functionality out of Compass and into something more similar to asset_hash with Rack-based rewrites
  # Scenario: Enabling an asset host and referencing assets in CSS with URL fragments are rewritten correctly
  #   Given a successfully built app at "asset-hash-host-app"
  #   When I cd to "build"

  #   Then the following files should exist:
  #     | images/100px-5fd6fb90.jpg |
  #     | stylesheets/fragment-c058ecb2.css |
  #   And the following files should not exist:
  #     | images/100px.jpg |

  #   And the file "stylesheets/fragment-c058ecb2.css" should contain "http://middlemanapp.com/images/100px-5fd6fb90.jpg#test"
  #   And the file "stylesheets/fragment-c058ecb2.css" should not contain "http://middlemanapp.com/images/100px.jpg#test"
