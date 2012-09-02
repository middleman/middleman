Feature: i18n Builder
  In order to preview localized html
  
  Scenario: Running localize with the default config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
      | es/index.html                                 |
      | es/hola.html                                  |
    Then the following files should not exist:
      | en/index.html                                 |
    And the file "index.html" should contain "Howdy"  
    And the file "hello.html" should contain "Hello World"
    And the file "es/index.html" should contain "Como Esta?"
    And the file "es/hola.html" should contain "Hola World"
    
  Scenario: Running localize with the alt path config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :path => "/lang_:locale/"
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
      | lang_es/index.html                            |
      | lang_es/hola.html                             |
    Then the following files should not exist:
      | lang_en/index.html                            |
    And the file "index.html" should contain "Howdy"  
    And the file "hello.html" should contain "Hello World"
    And the file "lang_es/index.html" should contain "Como Esta?"
    And the file "lang_es/hola.html" should contain "Hola World"
    
  Scenario: Running localize with the alt root config
    Given a fixture app "i18n-alt-root-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :templates_dir => "lang_data"
      """
    Given a successfully built app at "i18n-alt-root-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
      | es/index.html                                 |
      | es/hola.html                                  |
    Then the following files should not exist:
      | en/index.html                                 |
    And the file "index.html" should contain "Howdy"  
    And the file "hello.html" should contain "Hello World"
    And the file "es/index.html" should contain "Como Esta?"
    And the file "es/hola.html" should contain "Hola World"
    
  Scenario: Running localize with the lang map config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :lang_map => { :en => :english, :es => :spanish }
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
      | spanish/index.html                            |
      | spanish/hola.html                             |
    Then the following files should not exist:
      | english/index.html                            |
    And the file "index.html" should contain "Howdy"  
    And the file "hello.html" should contain "Hello World"
    And the file "spanish/index.html" should contain "Como Esta?"
    And the file "spanish/hola.html" should contain "Hola World"
    
  Scenario: Running localize with the no mount config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :mount_at_root => false
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | en/index.html                                 |
      | en/hello.html                                 |
      | es/index.html                                 |
      | es/hola.html                                  |
    Then the following files should not exist:
      | index.html                                    |
      | hello.html                                    |
    And the file "en/index.html" should contain "Howdy"  
    And the file "en/hello.html" should contain "Hello World"
    And the file "es/index.html" should contain "Como Esta?"
    And the file "es/hola.html" should contain "Hola World"
    
  Scenario: Running localize with the subset config
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n, :langs => [:en]
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
    Then the following files should not exist:
      | en/index.html                                 |
      | es/index.html                                 |
      | es/hola.html                                  |
    And the file "index.html" should contain "Howdy"  
    And the file "hello.html" should contain "Hello World"
    
  Scenario: Running localize with relative_assets
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      activate :relative_assets
      """
    Given a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html                                    |
      | hello.html                                    |
      | es/index.html                                 |
      | es/hola.html                                  |
    And the file "index.html" should contain '"stylesheets/site.css"'
    And the file "hello.html" should contain '"stylesheets/site.css"'
    And the file "es/index.html" should contain '"../stylesheets/site.css"'
    And the file "es/hola.html" should contain '"../stylesheets/site.css"'