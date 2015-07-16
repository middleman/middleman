module Middleman
  class PreviewServer
    # Probe for tcp ports
    #
    # This one first tries `try_port` if this is not available use the free
    # port returned by TCPServer.
    class TcpPortProber
      # Check for port
      #
      # @param [Integer] try_port
      #   The port to be checked
      #
      # @return [Integer]
      #   The port
      def port(try_port)
        server = TCPServer.open(try_port)
        server.close

        try_port
      rescue
        server = TCPServer.open(0)
        port = server.addr[1]
        server.close

        port
      end
    end
  end
end
