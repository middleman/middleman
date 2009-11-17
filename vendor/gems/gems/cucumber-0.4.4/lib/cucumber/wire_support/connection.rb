require 'timeout'
require 'cucumber/wire_support/wire_protocol'

module Cucumber
  module WireSupport
    class Connection
      include WireProtocol
      
      def initialize(config)
        @host, @port = config['host'], config['port']
      end
      
      def call_remote(response_handler, message, params)
        timeout = 3
        packet = WirePacket.new(message, params)

        begin
          send_data_to_socket(packet.to_json, timeout)
          response = fetch_data_from_socket(timeout)
          response.handle_with(response_handler)
        rescue Timeout::Error
          raise "Timed out calling server with message #{message}"
        end
      end

      private
      
      def send_data_to_socket(data, timeout)
        Timeout.timeout(timeout) { socket.puts(data) }
      end

      def fetch_data_from_socket(timeout)
        raw_response = Timeout.timeout(timeout) { socket.gets }
        WirePacket.parse(raw_response)
      end

      def socket
        @socket ||= TCPSocket.new(@host, @port)
      end
    end
  end
end