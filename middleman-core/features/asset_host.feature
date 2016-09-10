Feature: Alternate between multiple asset hosts

  Scenario: Set single host with inline-option
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host, host: "http://assets1.example.com"
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see "'.google-analytics.com/ga.js'"
    Then I should see 'src="https://code.jquery.com/jquery-2.1.3.min.js"'
    Then I should see content matching %r{http://assets1.example.com/}
    Then I should not see content matching %r{http://assets1.example.com//}
    Then I should see content matching %r{<a href="https://github.com/angular/angular.js">Angular.js</a>}
    Then I should see content matching %r{'//www.example.com/script.js'}
    When I go to "/stylesheets/asset_host.css"
    Then I should see content matching %r{http://assets1.example.com/}
    Then I should not see content matching %r{http://assets1.example.com//}
    When I go to "/javascripts/asset_host.js"
    Then I should not see content matching %r{http://assets1.example.com/}

  Scenario: Set proc host with inline-option
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host, host: Proc.new { |asset|
        hash = Digest::MD5.digest(asset).bytes.map!(&:ord).reduce(&:+)
        "http://assets%d.example.com" % (hash % 4)
      }
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see 'src="https://code.jquery.com/jquery-2.1.3.min.js"'
    Then I should see content matching %r{http://assets1.example.com/}
    Then I should not see content matching %r{http://assets1.example.com//}
    Then I should see content matching %r{<a href="https://github.com/angular/angular.js">Angular.js</a>}
    Then I should see content matching %r{'//www.example.com/script.js'}
    When I go to "/stylesheets/asset_host.css"
    Then I should see content matching %r{http://assets1.example.com/}
    Then I should not see content matching %r{http://assets1.example.com//}

  Scenario: Hosts are not rewritten for rewrite ignored paths
    Given a fixture app "asset-host-app"
    And a file named "config.rb" with:
      """
      activate :asset_host, host: "http://assets1.example.com", rewrite_ignore: [
        '/stylesheets/asset_host.css',
      ]
      """
    And the Server is running
    When I go to "/asset_host.html"
    Then I should see content matching %r{http://assets1.example.com/}
    When I go to "/stylesheets/asset_host.css"
    Then I should not see content matching %r{http://assets1.example.com/}
