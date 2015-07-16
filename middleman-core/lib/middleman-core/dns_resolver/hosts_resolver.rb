module Middleman
  class DnsResolver
    # Use network name server to resolve ips and names
    class HostsResolver
      private

      attr_reader :resolver

      public

      def initialize(opts={})
        # using the splat operator works around a non-existing HOSTSRC variable
        # using nil as input does not work, but `*[]` does and then Resolv::Hosts
        # uses its defaults
        @resolver = opts.fetch(:resolver, Resolv::Hosts.new(*hosts_file))
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
      rescue Resolv::ResolvError
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
      rescue Resolv::ResolvError
        []
      end

      private

      # Path to hosts file
      #
      # This looks for MM_HOSTSRC in your environment
      #
      # @return [Array]
      #   This needs to be an array, to make the splat operator work
      #
      # @example
      #   # <ip> <hostname>
      #   127.0.0.1 localhost.localhost localhost
      def hosts_file
        return [ENV['MM_HOSTSRC']] if ENV.key?('MM_HOSTSRC') && File.file?(ENV['MM_HOSTSRC'])

        []
      end
    end
  end
end
