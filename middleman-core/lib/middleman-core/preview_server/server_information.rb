require 'middleman-core/dns_resolver'
require 'middleman-core/preview_server/information'
require 'middleman-core/preview_server/network_interface_inventory'
require 'middleman-core/preview_server/tcp_port_prober'
require 'middleman-core/preview_server/server_information_validator'

module Middleman
  class PreviewServer
    # This class holds all information which the preview server needs to setup a listener
    #
    # * server name
    # * bind address
    # * port
    #
    # Furthermore it probes for a free tcp port, if the default one 4567 is not available.
    class ServerInformation
      private

      attr_reader :resolver, :validator, :network_interface_inventory, :informations, :tcp_port_prober

      public

      attr_writer :https

      def initialize(opts={})
        @resolver     = opts.fetch(:resolver, DnsResolver.new)
        @validator    = opts.fetch(:validator, ServerInformationValidator.new)
        @network_interface_inventory = opts.fetch(:network_interface_inventory, NetworkInterfaceInventory.new)
        @tcp_port_prober = opts.fetch(:tcp_port_prober, TcpPortProber.new)

        @informations = []
        @informations << AllInterfaces
        @informations << AllIpv4Interfaces
        @informations << AllIpv6Interfaces
        @informations << ServerNameIsIpInformation
        @informations << ServerNameInformation
        @informations << BindAddressInformation
        @informations << BindAddressAndServerNameInformation
        @informations << DefaultInformation
      end

      # The information
      #
      # Is cached
      def information
        return @information if @information

        # The `DefaultInformation`-class always returns `true`, so there's
        # always a klass available and find will never return nil
        listener_klass = informations.find { |l| l.matches? bind_address: @bind_address, server_name: @server_name }
        @information = listener_klass.new(bind_address: @bind_address, server_name: @server_name)

        @information.show_me_network_interfaces(network_interface_inventory)
        @information.resolve_me(resolver)
        @information.port = tcp_port_prober.port(@port)
        @information.validate_me(validator)

        @information
      end

      # Use a middleman configuration to get information
      #
      # @param [#[]] config
      #   The middleman config
      def use(config)
        @bind_address = config[:bind_address]
        @port         = config[:port]
        @server_name  = config[:server_name]
        @https        = config[:https]

        config[:bind_address] = bind_address
        config[:port]         = port
        config[:server_name]  = server_name
        config[:https]        = https?
      end

      # Make information of internal server class avaible to make debugging
      # easier. This can be used to log the class which was used to determine
      # the preview server settings
      #
      # @return [String]
      #   The name of the class
      def handler
        information.class.to_s
      end

      # Is the server information valid?
      #
      # This is used to output a helpful error message, which can be stored in
      # `#reason`.
      #
      # @return [TrueClass, FalseClass]
      #   The result
      def valid?
        information.valid?
      end

      # The reason why the information is NOT valid
      #
      # @return [String]
      #   The reason why the information is not valid
      def reason
        information.reason
      end

      # The server name
      #
      # @return [String]
      #   The name of the server
      def server_name
        information.server_name
      end

      # The bind address of server
      #
      # @return [String]
      #   The bind address of the server
      def bind_address
        information.bind_address
      end

      # The port on which the server should listen
      #
      # @return [Integer]
      #   The port number
      def port
        information.port
      end

      # A list of site addresses
      #
      # @return [Array]
      #   A list of addresses which can be used to access the middleman preview
      #   server
      def site_addresses
        information.site_addresses
      end

      # A list of listeners
      #
      # @return [Array]
      #   A list of bind address where the
      def listeners
        information.listeners
      end

      # Is https enabled?
      def https?
        @https == true
      end
    end
  end
end
