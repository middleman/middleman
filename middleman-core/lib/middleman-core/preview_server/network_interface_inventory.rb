require 'middleman-core/preview_server/server_ip_address'

module Middleman
  class PreviewServer
    # This holds information about local network interfaces on the user systemd
    class NetworkInterfaceInventory
      # Return all ip interfaces
      class All
        def network_interfaces
          ipv4_addresses = Socket.ip_address_list.select(&:ipv4?).map { |ai| ServerIpv4Address.new(ai.ip_address) }
          ipv6_addresses = Socket.ip_address_list.select(&:ipv6?).map { |ai| ServerIpv6Address.new(ai.ip_address) }

          ipv4_addresses + ipv6_addresses
        end

        def self.match?(*)
          true
        end
      end

      # Return all ipv4 interfaces
      class Ipv4
        def network_interfaces
          Socket.ip_address_list.select { |ai| ai.ipv4? && !ai.ipv4_loopback? }.map { |ai| ServerIpv4Address.new(ai.ip_address) }
        end

        def self.match?(type)
          :ipv4 == type
        end
      end

      # Return all ipv6 interfaces
      class Ipv6
        def network_interfaces
          Socket.ip_address_list.select { |ai| ai.ipv6? && !ai.ipv6_loopback? }.map { |ai| ServerIpv6Address.new(ai.ip_address) }
        end

        def self.match?(type)
          :ipv6 == type
        end
      end

      private

      attr_reader :types

      public

      def initialize
        @types = []
        @types << Ipv4
        @types << Ipv6
        @types << All
      end

      # Return ip interfaces
      #
      # @param [Symbol] type
      #   The type of interface which should be returned
      def network_interfaces(type=:all)
        types.find { |t| t.match? type.to_sym }.new.network_interfaces
      end
    end
  end
end
