module Middleman
  class DnsResolver
    # Use network name server to resolve ips and names
    class BasicNetworkResolver
      private

      attr_reader :resolver, :timeouts

      public

      def initialize(opts={})
        @timeouts = opts.fetch(:timeouts, 2)
      end

      # Get names for ip
      #
      # @param [#to_s] ip
      #   The ip to resolve into names
      #
      # @return [Array]
      #   Array of Names
      def getnames(ip)
        resolver.getnames(ip.to_s).map(&:to_s)
      rescue Resolv::ResolvError, Errno::EADDRNOTAVAIL
        []
      end

      # Get ips for name
      #
      # @param [#to_s] name
      #   The name to resolve into ips
      #
      # @return [Array]
      #   Array of ipaddresses
      def getaddresses(name)
        resolver.getaddresses(name.to_s).map(&:to_s)
      rescue Resolv::ResolvError, Errno::EADDRNOTAVAIL
        []
      end

      # Set timeout for lookup
      #
      # @param [Integer] value
      #   The timeout value
      def timeouts=(timeouts)
        return if RUBY_VERSION < '2'

        resolver.timeouts = timeouts
      end
    end
  end
end
