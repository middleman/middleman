Feature: Minify Javascript
  In order reduce bytes sent to client and appease YSlow

  Background:
    Given current environment is "build"

  Scenario: Rendering inline js with the feature disabled
    Given "minify_javascript" feature is "disabled"
    And the Server is running at "minify-js-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script type='text/javascript'>
      //<![CDATA[
        ;(function() {
          this;
          should();
          all.be();
          on = { one: line };
        })();
      //]]>
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
    Given the Server is running at "passthrough-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script type='text/javascript'>
      //<![CDATA[
        ;(function() {
          this;
          should();
          all.be();
          on = { one: line };
        })();
      //]]>
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

  Scenario: Rendering inline js with the feature enabled
    Given "minify_javascript" feature is "enabled"
    And the Server is running at "minify-js-app"
    When I go to "/inline-js.html"
    Then I should see:
    """
    <script type='text/javascript'>
      //<![CDATA[
    (function(){this,should(),all.be(),on={one:line}})();
      //]]>
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
    Given "minify_javascript" feature is "enabled"
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
    Given "minify_javascript" feature is "enabled"
    And the Server is running at "minify-js-app"
    When I go to "/inline-coffeescript.html"
    Then I should see "6" lines
  
  Scenario: Rendering external js (coffeescript) with the feature enabled
    Given "minify_javascript" feature is "enabled"
    And the Server is running at "minify-js-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see "1" lines
    
  Scenario: Rendering inline js (coffeescript) with a passthrough minifier
    Given the Server is running at "passthrough-app"
    When I go to "/inline-coffeescript.html"
    Then I should see "16" lines
    
  Scenario: Rendering external js (coffeescript) with a passthrough minifier
    And the Server is running at "passthrough-app"
    When I go to "/javascripts/coffee_test.js"
    Then I should see "11" lines
    