require 'middleman-core/dns_resolver/basic_network_resolver'

module Middleman
  class DnsResolver
    # Use network name server to resolve ips and names
    class LocalLinkResolver < BasicNetworkResolver
      def initialize(opts={})
        super

        @timeouts = opts.fetch(:timeouts, 1)
        @resolver = opts.fetch(:resolver, Resolv::MDNS.new(nameserver_config))

        self.timeouts = timeouts
      end

      private

      # Hosts + Ports for MDNS resolver
      #
      # This looks for MM_MDNSRC in your environment. If you are going to use
      # IPv6-addresses: Make sure you do not forget to add the port at the end.
      #
      # MM_MDNSRC=ip:port ip:port
      #
      # @return [Hash]
      #   Returns the configuration for the nameserver
      #
      # @example
      #   export MM_MDNSRC="224.0.0.251:5353 ff02::fb:5353"
      #
      def nameserver_config
        return unless ENV.key?('MM_MDNSRC') && ENV['MM_MDNSRC']

        address, port = ENV['MM_MDNSRC'].split(/:/)

        {
          nameserver_port: [[address, port.to_i]]
        }
      rescue StandardError
        {}
      end
    end
  end
end
