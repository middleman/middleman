require 'ipaddr'
require 'active_support/core_ext/object/blank'
require 'middleman-core/preview_server/checks'
require 'middleman-core/preview_server/server_hostname'
require 'middleman-core/preview_server/server_ip_address'

module Middleman
  class PreviewServer
    # Basic information class to wrap common behaviour
    class BasicInformation
      private

      attr_reader :checks, :network_interfaces_inventory

      public

      attr_accessor :bind_address, :server_name, :port, :reason, :valid
      attr_reader :listeners, :site_addresses

      # Create instance
      #
      # @param [String] bind_address
      #   The bind address of the server
      #
      # @param [String] server_name
      #   The name of the server
      #
      # @param [Integer] port
      #   The port to listen on
      def initialize(opts={})
        @bind_address = ServerIpAddress.new(opts[:bind_address])
        @server_name  = ServerHostname.new(opts[:server_name])
        @port         = opts[:port]
        @valid        = true

        @site_addresses = []
        @listeners = []
        @checks = []

        # This needs to be check for each use case. Otherwise `Webrick` will
        # complain about that.
        @checks << Checks::InterfaceIsAvailableOnSystem.new
      end

      # Is the given information valid?
      def valid?
        valid == true
      end

      # Pass "self" to validator
      #
      # @param [#validate] validator
      #   The validator
      def validate_me(validator)
        validator.validate self, checks
      end

      def resolve_me(*)
        fail NoMethodError
      end

      # Get network information
      #
      # @param [#network_interfaces] inventory
      #   Get list of available network interfaces
      def show_me_network_interfaces(inventory)
        @network_interfaces_inventory = inventory
      end

      # Default is to get all network interfaces
      def local_network_interfaces
        network_interfaces_inventory.nil? ? [] : network_interfaces_inventory.network_interfaces(:all)
      end
    end

    # This only is used if no other parser is available
    #
    # The "default" behaviour is to fail because of "Checks::DenyAnyAny"
    class DefaultInformation < BasicInformation
      def initialize(*args)
        super

        # Make this fail
        @checks << Checks::DenyAnyAny.new
      end

      def resolve_me(*); end

      # Always true
      def self.matches?(*)
        true
      end
    end

    # This one is used if no bind address and no server name is given
    class AllInterfaces < BasicInformation
      def initialize(*args)
        super

        after_init
      end

      def self.matches?(opts={})
        opts[:bind_address].blank? && opts[:server_name].blank?
      end

      # Resolve ips
      def resolve_me(resolver)
        hostname          = ServerHostname.new(Socket.gethostname)
        hostname_ips      = resolver.ips_for(hostname)
        network_interface = ServerIpAddress.new(Array(local_network_interfaces).first)
        resolved_name     = ServerHostname.new(resolver.names_for(network_interface).first)

        if includes_array? local_network_interfaces, hostname_ips
          @server_name = hostname
          @site_addresses << hostname

          network_interface = ServerIpAddress.new((local_network_interfaces & hostname_ips).first)
        elsif RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
          @server_name = hostname
          @site_addresses << hostname
        elsif !resolved_name.blank?
          @server_name = resolved_name
          @site_addresses << resolved_name
        else
          @server_name = network_interface
        end

        @site_addresses << network_interface

        self
      end

      private

      def includes_array?(a, b)
        !(a & b).empty?
      end

      def after_init
        @listeners << ServerIpAddress.new('::')
        @listeners << ServerIpAddress.new('0.0.0.0')
      end
    end

    # This is used if bind address is 0.0.0.0, the server name needs to be
    # blank
    class AllIpv4Interfaces < AllInterfaces
      def self.matches?(opts={})
        opts[:bind_address] == '0.0.0.0' && opts[:server_name].blank?
      end

      # Use only ipv4 interfaces
      def local_network_interfaces
        network_interfaces_inventory.nil? ? [] : network_interfaces_inventory.network_interfaces(:ipv4)
      end

      private

      def after_init
        @listeners << ServerIpAddress.new('0.0.0.0')
      end
    end

    # This is used if bind address is ::, the server name needs to be blank
    class AllIpv6Interfaces < AllInterfaces
      def self.matches?(opts={})
        opts[:bind_address] == '::' && opts[:server_name].blank?
      end

      # Use only ipv6 interfaces
      def local_network_interfaces
        network_interfaces_inventory.nil? ? [] : network_interfaces_inventory.network_interfaces(:ipv6)
      end

      private

      def after_init
        @listeners << ServerIpAddress.new('::')
      end
    end

    # Used if a bind address is given and the server name is blank
    class BindAddressInformation < BasicInformation
      def initialize(*args)
        super

        @listeners << bind_address
        @site_addresses << bind_address
      end

      def self.matches?(opts={})
        !opts[:bind_address].blank? && opts[:server_name].blank?
      end

      # Resolv
      def resolve_me(resolver)
        @server_name = ServerHostname.new(resolver.names_for(bind_address).first)
        @site_addresses << @server_name unless @server_name.blank?

        self
      end
    end

    # Use if server name is given and bind address is blank
    class ServerNameInformation < BasicInformation
      def initialize(*args)
        super

        @checks << Checks::RequiresBindAddressIfServerNameIsGiven.new
        @site_addresses << server_name
      end

      def resolve_me(resolver)
        @bind_address = ServerIpAddress.new(resolver.ips_for(server_name).first)

        unless bind_address.blank?
          @listeners << bind_address
          @site_addresses << bind_address
        end

        self
      end

      def self.matches?(opts={})
        opts[:bind_address].blank? && !opts[:server_name].blank?
      end
    end

    # Only used if bind address and server name are given and bind address is
    # not :: or 0.0.0.0
    class BindAddressAndServerNameInformation < BasicInformation
      def initialize(*args)
        super

        @listeners << bind_address
        @site_addresses << server_name
        @site_addresses << bind_address

        @checks << Checks::ServerNameResolvesToBindAddress.new
      end

      def self.matches?(opts={})
        !opts[:bind_address].blank? && !opts[:server_name].blank? && !%w(:: 0.0.0.0).include?(opts[:bind_address])
      end

      def resolve_me(*); end
    end

    # If the server name is either an ipv4 or ipv6 address, e.g. 127.0.0.1 or
    # ::1, use this one
    class ServerNameIsIpInformation < BasicInformation
      def initialize(opts={})
        super

        ip = ServerIpAddress.new(server_name.to_s)

        @listeners << ip
        @site_addresses << ip
      end

      def resolve_me(*); end

      def self.matches?(opts={})
        ip = IPAddr.new(opts[:server_name])

        ip.ipv4? || ip.ipv6?
      rescue
        false
      end
    end
  end
end
