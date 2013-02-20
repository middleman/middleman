Feature: Minify Javascript
  In order reduce bytes sent to client and appease YSlow

  Scenario: Rendering inline js with the feature disabled
    Given a fixture app "minify-js-app"
    And a file named "config.rb" with:
      """
      """
    And the Server is running at "minify-js-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script>
      ;(function() {
        this;
        should();
        all.be();
        on = { one: line };
      })();
    </script>
    <script>
      ;(function() {
        this;
        should();
        too();
      })();
    </script>
    <script type='text/javascript'>
      //<!--
      ;(function() {
        one;
        line();
        here();
      })();
      //-->
    </script>
    <script type='text/html'>
      I'm a jQuery {{template}}.
    </script>
    """
    
  Scenario: Rendering inline js with a passthrough minifier
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      module ::PassThrough
        def self.compress(data)
          data
        end
      end

      activate :minify_javascript, :inline => true

      set :js_compressor, ::PassThrough

      page "/inline-js.html", :layout => false
      """
    And the Server is running at "passthrough-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script>
      ;(function() {
        this;
        should();
        all.be();
        on = { one: line };
      })();
    </script>
    <script>
      ;(function() {
        this;
        should();
        too();
      })();
    </script>
    <script type='text/javascript'>
      //<!--
      ;(function() {
        one;
        line();
        here();
      })();
      //-->
    </script>
    <script type='text/html'>
      I'm a jQuery {{template}}.
    </script>
    """

  Scenario: Rendering inline css with a passthrough minifier using activate-style compressor
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      module ::HelloCompressor
        def self.compress(data)
          "Hello"
        end
      end

      activate :minify_javascript, :inline => true, :compressor => ::HelloCompressor

      page "/inline-js.html", :layout => false
      """
    And the Server is running at "passthrough-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script>
      Hello
    </script>
    <script>
      Hello
    </script>
    <script type='text/javascript'>
      //<!--
    Hello
      //-->
    </script>
    <script type='text/html'>
      I'm a jQuery {{template}}.
    </script>
    """
    
  Scenario: Rendering inline js with the feature enabled
    Given a fixture app "minify-js-app"
    And a file named "config.rb" with:
      """
      activate :minify_javascript, :inline => true
      """
    And the Server is running at "minify-js-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script>
      (function(){this,should(),all.be(),on={one:line}})();
    </script>
    <script>
      (function(){this,should(),too()})();
    </script>
    <script type='text/javascript'>
      //<!--
    (function(){one,line(),here()})();
      //-->
    </script>
    <script type='text/html'>
      I'm a jQuery {{template}}.
    </script>
    """
    
  Scenario: Rendering external js with the feature enabled
    Given a fixture app "minify-js-app"
    And a file named "config.rb" with:
      """
      activate :minify_javascript
      """
    And the Server is running at "minify-js-app"
    When I go to "/javascripts/js_test.js"
    Then I should see "1" lines
    When I go to "/more-js/other.js"
    Then I should see "1" lines
    
  Scenario: Rendering external js with a passthrough minifier
    And the Server is running at "passthrough-app"
    When I go to "/javascripts/js_test.js"
    Then I should see "8" lines

  Scenario: Rendering inline js (coffeescript) with the feature enabled
    Given a fixture app "minify-js-app"
    And a file named "config.rb" with:
      """
      activate :minify_javascript, :inline => true
      """
    And the Server is running at "minify-js-app"
    When I go to "/inline-coffeescript.html"
    Then I should see "3" lines
  
  Scenario: Rendering external js (coffeescript) with the feature enabled
    Given a fixture app "minify-js-app"
    And a file named "config.rb" with:
      """
      activate :minify_javascript
      """
    And the Server is running at "minify-js-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see "1" lines
    
  Scenario: Rendering inline js (coffeescript) with a passthrough minifier
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      module ::PassThrough
        def self.compress(data)
          data
        end
      end

      activate :minify_javascript, :inline => true

      set :js_compressor, ::PassThrough

      page "/inline-coffeescript.html", :layout => false
      """
    And the Server is running at "passthrough-app"
    When I go to "/inline-coffeescript.html"
    Then I should see "13" lines
    
  Scenario: Rendering external js (coffeescript) with a passthrough minifier
    Given a fixture app "passthrough-app"
    And a file named "config.rb" with:
      """
      module ::PassThrough
        def self.compress(data)
          data
        end
      end

      activate :minify_javascript

      set :js_compressor, ::PassThrough
      """
    And the Server is running at "passthrough-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see "11" lines
    