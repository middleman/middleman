require 'ipaddr'
require 'forwardable'

module Middleman
  class PreviewServer
    class ServerIpAddress
      def self.new(ip_address)
        @parser = []
        @parser << ServerIpv6Address
        @parser << ServerIpv4Address

        @parser.find { |p| p.match? ip_address }.new(ip_address)
      end
    end

    class BasicServerIpAddress < SimpleDelegator
    end

    class ServerIpv4Address < BasicServerIpAddress
      def to_browser
        __getobj__.to_s
      end

      def self.match?(*)
        true
      end
    end

    class ServerIpv6Address < BasicServerIpAddress
      def to_s
        __getobj__.sub(/%.*$/, '')
      end

      def to_browser
        format('[%s]', to_s)
      end

      if RUBY_VERSION < '2'
        def self.match?(str)
          str = str.to_s.sub(/%.*$/, '')
          IPAddr.new(str).ipv6?
        rescue StandardError
          false
        end
      else
        def self.match?(str)
          str = str.to_s.sub(/%.*$/, '')
          IPAddr.new(str).ipv6?
        rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
          false
        end
      end
    end
  end
end
