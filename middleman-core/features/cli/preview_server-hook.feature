Feature: Run preview server before hook

  Scenario: When run
    Given a fixture app "preview-server-hook-app"
    And the default aruba timeout is 30 seconds
    When I run `middleman server --server-name localhost --bind-address 127.0.0.1` interactively
    And I stop middleman if the output contains:
    """
    ### END ###
    """
    Then the output should contain:
    """
    /// 127.0.0.1:4567 ///
    /// 4567 ///
    /// localhost ///
    /// http://localhost:4567 ///
    """
