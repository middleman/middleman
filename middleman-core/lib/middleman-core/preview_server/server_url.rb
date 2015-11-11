require 'ipaddr'

module Middleman
  class PreviewServer
    # This builds the server urls for the preview server
    class ServerUrl
      private

      attr_reader :hosts, :port, :https, :format_output

      public

      def initialize(opts={})
        @hosts = opts.fetch(:hosts)
        @port  = opts.fetch(:port)
        @https = opts.fetch(:https, false)
        @format_output = opts.fetch(:format_output, true)
      end

      # Return bind addresses
      #
      # @return [Array]
      #   List of bind addresses of format host:port
      def to_bind_addresses
        if format_output
          hosts.map { |l| format('"%s:%s"', l.to_s, port) }
        else
          hosts.map { |l| format('%s:%s', l.to_s, port) }
        end
      end

      # Return server urls
      #
      # @return [Array]
      #   List of urls of format http://host:port
      def to_urls
        if format_output
          hosts.map { |l| format('"%s://%s:%s"', https? ? 'https' : 'http', l.to_browser, port) }
        else
          hosts.map { |l| format('%s://%s:%s', https? ? 'https' : 'http', l.to_browser, port) }
        end
      end

      # Return server config urls
      #
      # @return [Array]
      #   List of urls of format http://host:port/__middleman
      def to_config_urls
        if format_output
          hosts.map { |l| format('"%s://%s:%s/__middleman"', https? ? 'https' : 'http', l.to_browser, port) }
        else
          hosts.map { |l| format('%s://%s:%s/__middleman', https? ? 'https' : 'http', l.to_browser, port) }
        end
      end

      private

      def https?
        https == true
      end
    end
  end
end
