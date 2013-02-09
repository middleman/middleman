Feature: i18n Preview
  In order to preview localized html
  
  Scenario: Running localize with the default config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When I go to "/en/index.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "Como Esta?"
    When I go to "/es/hola.html"
    Then I should see "Hola World"

  Scenario: A template changes i18n during preview
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given the Server is running at "i18n-test-app"
    And the file "locales/en.yml" has the contents
      """
      ---
      en:
        greetings: "Howdy"
        hi: "Hello"
      """
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When the file "locales/en.yml" has the contents
      """
      ---
      en:
        greetings: "How You Doin"
        hi: "Sup"
      """
    When I go to "/"
    Then I should see "How You Doin"
    When I go to "/hello.html"
    Then I should see "Sup World"

  Scenario: Running localize with the alt path config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :path => "/lang_:locale/"
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When I go to "/lang_en/index.html"
    Then I should see "File Not Found"
    When I go to "/lang_es/index.html"
    Then I should see "Como Esta?"
    When I go to "/lang_es/hola.html"
    Then I should see "Hola World"
    
    
  Scenario: Running localize with the alt root config
    Given a fixture app "i18n-alt-root-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :templates_dir => "lang_data"
      """
    Given the Server is running at "i18n-alt-root-app"
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When I go to "/en/index.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "Como Esta?"
    When I go to "/es/hola.html"
    Then I should see "Hola World"
    
  Scenario: Running localize with the lang map config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :lang_map => { :en => :english, :es => :spanish }
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When I go to "/english/index.html"
    Then I should see "File Not Found"
    When I go to "/spanish/index.html"
    Then I should see "Como Esta?"
    When I go to "/spanish/hola.html"
    Then I should see "Hola World"

  Scenario: Running localize with a non-English mount config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :mount_at_root => :es
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/en/index.html"
    Then I should see "Howdy"
    When I go to "/en/hello.html"
    Then I should see "Hello World"
    When I go to "/"
    Then I should see "Como Esta?"
    When I go to "/hola.html"
    Then I should see "Hola World"
    When I go to "/hello.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "File Not Found"
    When I go to "/es/hola.html"
    Then I should see "File Not Found"

  Scenario: Running localize with a non-English lang subset
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :langs => :es
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/en/index.html"
    Then I should see "File Not Found"
    When I go to "/en/hello.html"
    Then I should see "File Not Found"
    When I go to "/"
    Then I should see "Como Esta?"
    When I go to "/hola.html"
    Then I should see "Hola World"
    When I go to "/hello.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "File Not Found"
    When I go to "/es/hola.html"
    Then I should see "File Not Found"
    
    
  Scenario: Running localize with the no mount config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :mount_at_root => false
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/en/index.html"
    Then I should see "Howdy"
    When I go to "/en/hello.html"
    Then I should see "Hello World"
    When I go to "/"
    Then I should see "File Not Found"
    When I go to "/hello.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "Como Esta?"
    When I go to "/es/hola.html"
    Then I should see "Hola World"
    
  Scenario: Running localize with the subset config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :langs => [:en]
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see "Howdy"
    When I go to "/hello.html"
    Then I should see "Hello World"
    When I go to "/en/index.html"
    Then I should see "File Not Found"
    When I go to "/es/index.html"
    Then I should see "File Not Found"
    When I go to "/es/hola.html"
    Then I should see "File Not Found"
    
  Scenario: Running localize with relative_assets
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      activate :relative_assets
      """
    Given the Server is running at "i18n-test-app"
    When I go to "/"
    Then I should see '"stylesheets/site.css"'
    When I go to "/hello.html"
    Then I should see '"stylesheets/site.css"'
    When I go to "/es/index.html"
    Then I should see '"../stylesheets/site.css"'
    When I go to "/es/hola.html"
    Then I should see '"../stylesheets/site.css"'