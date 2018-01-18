Feature: Ignoring paths
  Scenario: Ignore a single path (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And a successfully built app at "ignore-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
    And the following files should not exist:
      | plain.html |
      | about.html |

  Scenario: Ignore a single path (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
       """
       ignore 'about.html.erb'
       ignore 'plain.html'
       """
    And the Server is running
    When I go to "/index.html"
    Then I should not see "File Not Found"
    When I go to "/plain.html"
    Then I should see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"

  Scenario: Ignoring collected values
    Given a fixture app "ignore-app"
    And a file named "data/ignores.yaml" with:
      """
      ---
      - "plain"
      """
    And a file named "config.rb" with:
       """
       data.ignores.each do |name|
         ignore "#{name}.html"
       end
       """
    And the Server is running
    When I go to "/plain.html"
    Then I should see "File Not Found"
    When I go to "/about.html"
    Then I should not see "File Not Found"

    When the file "data/ignores.yaml" has the contents
      """
      ---
      - "about"
      """
    When I go to "/plain.html"
    Then I should not see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"

  Scenario: Ignore a globbed path (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore '*.erb'
      ignore 'reports/*'
      ignore 'images/**/*.png'
      """
    And a successfully built app at "ignore-app"
    When I cd to "build"
    Then the following files should exist:
      | plain.html |
      | images/portrait.jpg |
      | images/pic.png |
    And the following files should not exist:
      | about.html |
      | index.html |
      | reports/index.html |
      | reports/another.html |
      | images/icons/messages.png |

  Scenario: Ignore a globbed path (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore '*.erb'
      ignore 'reports/*'
      ignore 'images/**/*.png'
      """
    And the Server is running
    When I go to "/plain.html"
    Then I should not see "File Not Found"
    When I go to "/images/portrait.jpg"
    Then I should not see "File Not Found"
    When I go to "/images/pic.png"
    Then I should not see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"
    When I go to "/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/another.html"
    Then I should see "File Not Found"
    When I go to "/images/icons/messages.png"
    Then I should see "File Not Found"

  Scenario: Ignore a regex (build)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore /^.*\.erb/
      ignore /^reports\/.*/
      ignore /^images\.*\.png/
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/plain.html |
      | build/images/portrait.jpg |
      | build/images/pic.png |
    And the following files should not exist:
      | build/about.html |
      | build/index.html |
      | build/reports/index.html |
      | build/reports/another.html |
      | build/images/icons/messages.png |

  Scenario: Ignore a regex (server)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore /^.*\.erb/
      ignore /^reports\/.*/
      ignore /^images\.*\.png/
      """
    And the Server is running
    When I go to "/plain.html"
    Then I should not see "File Not Found"
    When I go to "/images/portrait.jpg"
    Then I should not see "File Not Found"
    When I go to "/images/pic.png"
    Then I should not see "File Not Found"
    When I go to "/about.html"
    Then I should see "File Not Found"
    When I go to "/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/index.html"
    Then I should see "File Not Found"
    When I go to "/reports/another.html"
    Then I should see "File Not Found"
    When I go to "/images/icons/messages.png"
    Then I should see "File Not Found"

  Scenario: Ignore localized templates (build)
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      ignore 'localizable/hello.html.erb'
      ignore /morning/
      ignore 'localizable/*.md'
      """
    And a successfully built app at "i18n-test-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | es/index.html |
    And the following files should not exist:
      | hello.html |
      | morning.html |
      | one.html |
      | es/hola.html |
      | es/manana.html |
      | es/una.html |
      | es/hello.html |
      | es/morning.html |
      | es/one.html |
    And the file "index.html" should contain "Howdy"
    And the file "es/index.html" should contain "Como Esta?"

  Scenario: Ignore localized templates (server)
    Given a fixture app "i18n-test-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      ignore 'localizable/hello.html.erb'
      ignore /morning/
      ignore 'localizable/*.md'
      """
    And the Server is running
    When I go to "/index.html"
    Then I should not see "File Not Found"
    When I go to "/es/index.html"
    Then I should not see "File Not Found"
    When I go to "/hello.html"
    Then I should see "File Not Found"
    When I go to "/morning.html"
    Then I should see "File Not Found"
    When I go to "/one.html"
    Then I should see "File Not Found"
    When I go to "/es/hola.html"
    Then I should see "File Not Found"
    When I go to "/es/manana.html"
    Then I should see "File Not Found"
    When I go to "/es/una.html"
    Then I should see "File Not Found"
