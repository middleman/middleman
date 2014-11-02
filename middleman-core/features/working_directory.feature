Feature: Honour working directory 
  Honour the working directory during testing
  In order to support helpers which work with the current directories

  Scenario: Set working directory for helpers in tests
    Given a fixture app "empty-app"
    And a file named "source/index.erb" with:
    """
    <%= Dir.getwd %>
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see:
    """
    aruba
    """

  Scenario: Set working directory for config.rb in tests
    Given a fixture app "empty-app"
    And a file named "config.rb" with:
    """
    set :my_working_directory, Dir.getwd
    """
    And a file named "source/index.erb" with:
    """
    <%= my_working_directory %>
    """
    And the Server is running
    When I go to "/index.html"
    Then I should see:
    """
    aruba
    """
