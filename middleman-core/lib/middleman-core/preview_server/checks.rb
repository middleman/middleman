require 'ipaddr'

module Middleman
  class PreviewServer
    # Checks for input of preview server
    module Checks
      # This one will get all default setup
      class BasicCheck; end

      # This checks if the server name resolves to the bind_address
      #
      # If the users enters:
      #
      # 1. server_name: www.example.com (10.0.0.1)
      # 2. bind_address: 127.0.0.01
      #
      # This validation will fail
      class ServerNameResolvesToBindAddress < BasicCheck
        private

        attr_reader :resolver

        public

        def initialize
          @resolver = DnsResolver.new
        end

        # Validate
        #
        # @param [Information] information
        #   The information to be validated
        def validate(information)
          return if resolver.ips_for(information.server_name).include? information.bind_address

          information.valid = false
          information.reason = format('Server name "%s" does not resolve to bind address "%s"', information.server_name, information.bind_address)
        end
      end

      # This validation fails if the user chooses to use an ip address which is
      # not available on his/her system
      class InterfaceIsAvailableOnSystem < BasicCheck
        # Validate
        #
        # @param [Information] information
        #   The information to be validated
        def validate(information)
          return if information.bind_address.blank? || information.local_network_interfaces.include?(information.bind_address.to_s) || %w(0.0.0.0 ::).any? { |b| information.bind_address == b } || IPAddr.new('127.0.0.0/8').include?(information.bind_address.to_s)

          information.valid = false
          information.reason = format('Bind address "%s" is not available on your system. Please use one of %s', information.bind_address, information.local_network_interfaces.map { |i| %("#{i}") }.join(', '))
        end
      end

      # This one requires a bind address if the user entered a server name
      #
      # If the `bind_address` is blank this check will fail
      class RequiresBindAddressIfServerNameIsGiven < BasicCheck
        def validate(information)
          return unless information.bind_address.blank?

          information.valid = false
          information.reason = format('Server name "%s" does not resolve to an ip address', information.server_name)
        end
      end

      # This validation always fails
      class DenyAnyAny < BasicCheck
        # Validate
        #
        # @param [Information] information
        #   The information to be validated
        def validate(information)
          information.valid = false
          information.reason = 'Undefined combination of options "--server-name" and "--bind-address". If you think this is wrong, please file a bug at "https://github.com/middleman/middleman"'
        end
      end
    end
  end
end
