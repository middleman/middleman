Feature: Ignoring paths
  Scenario: Ignore a single path
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/plain.html |
      | build/about.html |

  Scenario: Ignore a globbed path    
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      ignore '*.erb'
      ignore 'reports/*'
      ignore 'images/**/*.png'
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

  Scenario: Ignore a regex
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

  Scenario: Ignore with directory indexes (source file)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about.html.erb'
      ignore 'plain.html'
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/about/index.html |
      | build/plain/index.html |

  Scenario: Ignore with directory indexes (output path splat)
    Given a fixture app "ignore-app"
    And a file named "config.rb" with:
      """
      activate :directory_indexes
      ignore 'about*'
      ignore 'plain*'
      """
    And a successfully built app at "ignore-app"
    Then the following files should exist:
      | build/index.html |
    And the following files should not exist:
      | build/about/index.html |
      | build/plain/index.html |
	  
  # Scenario: Ignore with directory indexes (output path index)
  #   Given a fixture app "ignore-app"
  #   And a file named "config.rb" with:
  #     """
  #     activate :directory_indexes
  #     ignore 'about/index.html'
  #     ignore 'plain/index.html'
  #     """
  #   And a successfully built app at "ignore-app"
  #   Then the following files should exist:
  #     | build/index.html |
  #   And the following files should not exist:
  #     | build/about/index.html |
  #     | build/plain/index.html |