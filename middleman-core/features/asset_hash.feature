Feature: Assets get file hashes appended to them and references to them are updated
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
      | stylesheets/site-8bc55985.css |
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
    And the file "stylesheets/site-8bc55985.css" should contain:
      """
      background-image: url("../images/100px-5fd6fb90.jpg")
      """
    And the file "index.html" should contain 'href="apple-touch-icon.png"'
    And the file "index.html" should contain 'href="stylesheets/site-8bc55985.css"'
    And the file "index.html" should contain 'src="javascripts/application-1d8d5276.js"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.jpg"'
    And the file "subdir/index.html" should contain 'href="../stylesheets/site-8bc55985.css"'
    And the file "index.html" should contain 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.gif"'
    And the file "index.html" should contain 'src="images/100px-1242c368.png"'
    And the file "subdir/index.html" should contain 'src="../javascripts/application-1d8d5276.js"'
    And the file "subdir/index.html" should contain 'src="../images/100px-5fd6fb90.jpg"'
    And the file "other/index.html" should contain 'href="../stylesheets/site-8bc55985.css"'
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
    And I should see 'href="stylesheets/site-d1a750ca.css"'
    And I should see 'href="stylesheets/fragment-99b76247.css"'
    And I should see 'src="javascripts/application-1d8d5276.js"'
    And I should see 'src="images/100px-5fd6fb90.jpg"'
    And I should see 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'
    And I should see 'src="images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="images/100px-5fd6fb90.jpg#test"'
    When I go to "/subdir/"
    Then I should see 'href="../stylesheets/site-d1a750ca.css"'
    And I should see 'src="../javascripts/application-1d8d5276.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="../stylesheets/site-d1a750ca.css"'
    And I should see 'src="../javascripts/application-1d8d5276.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    And I should see 'src="../images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="../images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="../images/100px-5fd6fb90.jpg#test"'
    When I go to "/javascripts/application-1d8d5276.js"
    Then I should see "img.src = '/images/100px-5fd6fb90.jpg'"
    When I go to "/stylesheets/site-d1a750ca.css"
    Then I should see 'background-image: url("../images/100px-5fd6fb90.jpg");'
    When I go to "/api.json"
    Then I should see 'images/100px-5fd6fb90.gif'
    And I should see 'images/100px-5fd6fb90.jpg'
    And I should see 'images/100px-1242c368.png'
    When I go to "/subdir/api.json"
    Then I should see 'images/100px-5fd6fb90.gif'
    And I should see 'images/100px-5fd6fb90.jpg'
    And I should see 'images/100px-1242c368.png'
    When I go to "/stylesheets/fragment-99b76247.css"
    And I should see 'url("../images/100px-5fd6fb90.jpg");'
    And I should see 'url("../images/100px-5fd6fb90.jpg?test");'
    And I should see 'url("../images/100px-5fd6fb90.jpg?#test");'
    And I should see 'url("../images/100px-5fd6fb90.jpg#test");'

  Scenario: Hashed assets work with Slim
    Given the Server is running at "asset-hash-app"
    When I go to "/slim.html"
    And I should see 'src="images/300px-59adce76.jpg"'
    And I should see 'src="images/100px-5fd6fb90.jpg"'
    And I should see 'srcset="images/100px-5fd6fb90.jpg 1x, images/200px-c11eb203.jpg 2x, images/300px-59adce76.jpg 3x"'

  Scenario: Enabling an asset host still produces hashed files and references (hash first)
    Given a fixture app "asset-hash-host-app"
    And a file named "config.rb" with:
      """
      set :sass_source_maps, false
      activate :asset_hash
      activate :directory_indexes
      activate :asset_host, host: 'http://middlemanapp.com'
      """
    Given the Server is running at "asset-hash-host-app"
    When I go to "/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    Then I should see 'href="http://middlemanapp.com/stylesheets/fragment-2902933e.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg#test"'
    When I go to "/subdir/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg#test"'
    When I go to "/stylesheets/fragment-2902933e.css"
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg");'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg?test");'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test");'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg#test");'

  Scenario: Enabling an asset host still produces hashed files and references (host first)
    Given a fixture app "asset-hash-host-app"
    And a file named "config.rb" with:
      """
      set :sass_source_maps, false
      activate :asset_host, host: 'http://middlemanapp.com'
      activate :directory_indexes
      activate :asset_hash
      """
    Given the Server is running at "asset-hash-host-app"
    When I go to "/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    Then I should see 'href="http://middlemanapp.com/stylesheets/fragment-2902933e.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg#test"'
    When I go to "/subdir/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-7474cadd.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg#test"'
    When I go to "/stylesheets/fragment-2902933e.css"
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg")'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg?test")'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg?#test")'
    And I should see 'url("http://middlemanapp.com/images/100px-5fd6fb90.jpg#test")'

  Scenario: The asset hash should change when a SASS partial changes
    Given the Server is running at "asset-hash-app"
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-4d4e34e6.css'
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 18px !important
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-ec347271.css'

  Scenario: The asset hash should change when a Rack-based filter changes
    Given a fixture app "asset-hash-app"
    And a file named "config.rb" with:
      """
      activate :asset_hash
      activate :relative_assets
      activate :directory_indexes
      require 'lib/middleware.rb'
      use ::Middleware
      """
    Given the Server is running at "asset-hash-app"
    When I go to "/"
    Then I should see 'href="stylesheets/site-5ad7def0.css'
    When I go to "stylesheets/site-5ad7def0.css"
    Then I should see 'background-image: url("../images/100px-5fd6fb90.jpg")'
    Then I should see 'Added by Rack filter'

  Scenario: Hashed-asset files are not produced for ignored paths
    Given a fixture app "asset-hash-app"
    And a file named "config.rb" with:
      """
      is_stylesheet = proc { |path| path.start_with? 'stylesheets' }
      activate :asset_hash, ignore: [
        %r(javascripts/*),
        'images/*',
        is_stylesheet
      ]
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
      | stylesheets/site.css |
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
      | stylesheets/site-7474cadd.css |

  Scenario: Hashed-asset files are not replaced for rewrite ignored paths
    Given a fixture app "asset-hash-app"
    And a file named "config.rb" with:
      """
      is_stylesheet = proc { |path| path.start_with? '/stylesheets' }
      activate :asset_hash, rewrite_ignore: [
        %r(javascripts/*),
        '/subdir/*',
        is_stylesheet
      ]
      activate :relative_assets
      activate :directory_indexes
      """
    And a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | subdir/index.html |
      | images/100px-5fd6fb90.jpg |
      | javascripts/application-1d8d5276.js |
      | stylesheets/site-8bc55985.css |
    And the following files should not exist:
      | images/100px.jpg |
      | javascripts/application.js |
      | stylesheets/site.css |
    And the file "javascripts/application-1d8d5276.js" should contain "img.src = '/images/100px.jpg'"
    And the file "stylesheets/site-8bc55985.css" should contain:
      """
      background-image: url("../images/100px.jpg")
      """
    And the file "index.html" should contain 'href="stylesheets/site-8bc55985.css"'
    And the file "index.html" should contain 'src="javascripts/application-1d8d5276.js"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.jpg"'
    And the file "subdir/index.html" should contain:
      """
      <h2>Image url3:</h2>
      <p><img src="../images/100px.jpg"></p>
      """

  Scenario: Already minified files should still be hashed
    Given a successfully built app at "asset-hash-minified-app"
    When I cd to "build"
    Then the following files should exist:
      | javascripts/jquery.min-276c87ff.js |
      | stylesheets/test-7de2ad06.css |
    And the following files should not exist:
      | javascripts/jquery.min.js |
    And the file "stylesheets/test-7de2ad06.css" should contain:
      """
      .no-bug{background-image:url(/images/100px-5fd6fb90.jpg)}
      .bug{content:"";background-image:url(/images/100px-5fd6fb90.jpg)}
      .no-bug{content:""; background-image:url(/images/100px-5fd6fb90.jpg)}
      """

  Scenario: Source map paths include the hash
    Given a successfully built app at "asset-hash-source-map"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | javascripts/application-4553338c.js |
      | javascripts/application.js-22cc2b5f.map |
      | index.html |
    And the following files should not exist:
      | javascripts/application.js |
      | javascripts/application.js.map |

    And the file "javascripts/application-4553338c.js" should contain "//# sourceMappingURL=application.js-22cc2b5f.map"

  Scenario: Hashes can contain a prefix
    Given a successfully built app at "asset-hash-prefix"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | javascripts/application-myprefix-4553338c.js |
      | javascripts/application.js-myprefix-22cc2b5f.map |
      | index.html |
    And the following files should not exist:
      | javascripts/application.js |
      | javascripts/application.js.map |

    And the file "javascripts/application-myprefix-4553338c.js" should contain "//# sourceMappingURL=application.js-myprefix-22cc2b5f.map"
