Feature: Valid Outlines

Scenario Outline: Joe fails to login
  Given I login as Joe without the '<Privilege>' privilege
  When I <Request Method> /admin/<Path>
  Then I should see the text "Sorry Joe, you're not allowed to see <Path>"
  
  Examples:
  | Privilege | Request Method | Path       |
  | user      | GET            | reports    |
  | user      | GET            | managers   |

Scenario Outline: Look at me ma no examples!
  Given I login as Joe without the '<Privilege>' privilege
  When I <Request Method> /admin/<Path>
  Then I should see the text "Sorry Joe, you're not allowed to see <Path>"
