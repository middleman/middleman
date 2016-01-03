Feature: Run the preview server

  As a software developer
  I want to start the preview server
  In order to view my changes immediately in the browser

  Background:
    Given a fixture app "preview-server-app"
    And the default aruba timeout is 30 seconds

  Scenario: Start the server with defaults
    When I run `middleman server` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    And the output should contain:
    """
    View your site at "http://
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://
    """

  Scenario: Start the server with defaults in verbose mode
    When I run `middleman server --verbose` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::4567", "0.0.0.0:4567"
    """
    And the output should contain:
    """
    View your site at "http://
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://
    """

  @wip
  Scenario: Start the server with defaults in verbose mode, when a local mdns server resolves the local hostname
    Given I start a mdns server for the local hostname
    When I run `middleman server --verbose` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::4567", "0.0.0.0:4567"
    """
    And the output should contain:
    """
    View your site at "http://
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://
    """

  Scenario: Start the server with bind address 127.0.0.1
    Given I have a local hosts file with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    127.0.0.1 localhost.localdomain localhost
    """
    When I run `middleman server --verbose --bind-address 127.0.0.1` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://127.0.0.1:4567/__middleman"
    """

  Scenario: Start the server with bind address 127.0.0.1 configured via config.rb
    Given I have a local hosts file with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    127.0.0.1 localhost.localdomain localhost
    """
    And a file named "config.rb" with:
    """
    set :bind_address, '127.0.0.1'
    """
    When I run `middleman server --verbose` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://127.0.0.1:4567/__middleman"
    """

  @wip
  Scenario: Start the server with bind address 127.0.0.5

    This will have no hostname attached because the hosts file, the DNS server
    and the MDNS-server do not know anything about 127.0.0.5

    When I run `middleman server --verbose --bind-address 127.0.0.5` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.5:4567"
    """
    And the output should contain:
    """
    View your site at "http://127.0.0.5:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://127.0.0.5:4567/__middleman"
    """

  Scenario: Start the server with bind address ::1
    Given a file named ".hosts" with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    ::1 localhost.localdomain localhost
    """
    When I run `middleman server --verbose --bind-address ::1` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "::1:4567"
    """
    And the output should contain:
    """
    View your site at "http://[::1]:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://[::1]:4567/__middleman"
    """

  Scenario: Start the server with bind address 0.0.0.0
    When I run `middleman server --verbose --bind-address 0.0.0.0` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "0.0.0.0:4567"
    """
    And the output should contain:
    """
    View your site at "http://
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://
    """

  Scenario: Start the server with bind address ::
    When I run `middleman server --verbose --bind-address ::` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::4567"
    """
    And the output should contain:
    """
    View your site at "http://
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://
    """

  Scenario: Start the server with server name "localhost"
    Given I have a local hosts file with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    127.0.0.1 localhost.localdomain localhost
    """
    When I run `middleman server --verbose --server-name localhost` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://localhost:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://localhost:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """

  Scenario: Start the server with server name "localhost" configured via config.rb
    Given I have a local hosts file with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    127.0.0.1 localhost.localdomain localhost
    """
    And a file named "config.rb" with:
    """
    set :server_name, 'localhost'
    """
    When I run `middleman server --verbose` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://localhost:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://localhost:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """

  Scenario: Start the server with server name "localhost" and bind address "127.0.0.1"
    Given I have a local hosts file with:
    """
    # <ip-address> <hostname.domain.org> <hostname>
    127.0.0.1 localhost.localdomain localhost
    """
    When I run `middleman server --verbose --server-name localhost --bind-address 127.0.0.1` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://localhost:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://localhost:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """

  Scenario: Start the server with server name "127.0.0.1"
    When I run `middleman server --verbose --server-name 127.0.0.1` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://127.0.0.1:4567/__middleman"
    """

  Scenario: Start the server with server name "::1"
    When I run `middleman server --verbose --server-name ::1` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "::1:4567"
    """
    And the output should contain:
    """
    View your site at "http://[::1]:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://[::1]:4567/__middleman"
    """

  Scenario: Start the server with https
    When I run `middleman server --verbose --https` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::4567", "0.0.0.0:4567"
    """
    And the output should contain:
    """
    View your site at "https://
    """
    And the output should contain:
    """
    Inspect your site configuration at "https://
    """

  Scenario: Start the server with port 65432
    When I run `middleman server --verbose --port 65432` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::65432", "0.0.0.0:65432"
    """

  Scenario: Start the server with port 65432 configured via config.rb
    Given a file named "config.rb" with:
    """
    set :port, 65432
    """
    When I run `middleman server --verbose` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to ":::65432", "0.0.0.0:65432"
    """

  @wip
  Scenario: Start the server when port is blocked by other middleman instance
    Given `middleman server` is running in background
    When I run `middleman server --verbose` interactively
    And I stop all commands if the output of the last command contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman uses a different port
    """

  Scenario: Start the server with bind address 1.1.1.1

    This should fail, because "1.1.1.1" is not an interface available on this computer.

    Given a file named ".hosts" with:
    """
    1.1.1.1  www.example.com www
    """
    When I run `middleman server --verbose --bind-address 1.1.1.1` interactively
    And I stop middleman if the output contains:
    """
    Running Middleman failed:
    """
    Then the output should contain:
    """
    Bind address "1.1.1.1" is not available on your system
    """

  Scenario: Start the server with server name www.example.com and bind address 0.0.0.0

    This should fail, because the user can just use `--server-name`. It does
    not make sense for `middleman` to only listen on `0.0.0.0` (IPv4 all
    interfaces), but not on `::` (IPv6 all interfaces). There are other tools
    like `iptables` (Linux-only) or better some `kernel`-configurations to make
    this possible.

    When I run `middleman server --verbose --server-name www.example.com --bind-address 0.0.0.0` interactively
    And I stop middleman if the output contains:
    """
    Running Middleman failed:
    """
    Then the output should contain:
    """
    Undefined combination of options "--server-name" and "--bind-address".
    """

  Scenario: Start the server with server name "www.example.com" and bind address "127.0.0.1"

    This should fail because the server name does not resolve to the ip address.

    Given a file named ".hosts" with:
    """
    1.1.1.1  www.example.com www
    """
    When I run `middleman server --verbose --server-name www.example.com --bind-address 127.0.0.1` interactively
    And I stop middleman if the output contains:
    """
    Running Middleman failed:
    """
    Then the output should contain:
    """
    Server name "www.example.com" does not resolve to bind address "127.0.0.1". Please fix that and try again.
    """

  Scenario: Start the server with server name "garbage.example.com"
    When I run `middleman server --verbose --server-name garbage.example.com` interactively
    And I stop middleman if the output contains:
    """
    Running Middleman failed:
    """
    Then the output should contain:
    """
    Server name "garbage.example.com" does not resolve to an ip address. Please fix that and try again.
    """

  Scenario: Start the server with server name "www.example.com" and the network name server is used to resolve the server name
    Given I have a local hosts file with:
    """
    # empty
    """
    And I start a mdns server with:
    """
    # empty
    """
    And I start a dns server with:
    """
    www.example.com: 127.0.0.1
    """
    When I run `middleman server --verbose --server-name www.example.com` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://www.example.com:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://www.example.com:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """

  @ruby-2.1
  @wip
  Scenario: Start the server with server name "host.local" and the link local name server is used to resolve the server name

    To make the mdns resolver resolve a name, it needs to end with ".local".
    Otherwise the resolver returns [].

    Given I have a local hosts file with:
    """
    # empty
    """
    And I start a mdns server with:
    """
    host.local: 127.0.0.1
    """
    When I run `middleman server --verbose --server-name host.local` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://host.local:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://host.local:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """

  @ruby-2.1
  @wip
  Scenario: Start the server with server name "host" and the link local name server is used to resolve the server name

    To make the mdns resolver resolve a name, it needs to end with ".local". If
    a plain hostname is given `middleman` appends ".local" automatically.

    Given I have a local hosts file with:
    """
    # empty
    """
    And I start a mdns server with:
    """
    host.local: 127.0.0.1
    """
    When I run `middleman server --verbose --server-name host` interactively
    And I stop middleman if the output contains:
    """
    Inspect your site configuration
    """
    Then the output should contain:
    """
    The Middleman preview server is bound to "127.0.0.1:4567"
    """
    And the output should contain:
    """
    View your site at "http://host.local:4567", "http://127.0.0.1:4567"
    """
    And the output should contain:
    """
    Inspect your site configuration at "http://host.local:4567/__middleman", "http://127.0.0.1:4567/__middleman"
    """
