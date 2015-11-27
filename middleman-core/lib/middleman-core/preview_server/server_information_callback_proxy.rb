module Middleman
  class PreviewServer
    # This class wraps server information to be used in call back
    #
    # * listeners
    # * port
    # * server name
    # * site_addresses
    #
    # All information is "dupped" and the callback is not meant to be used to
    # modify these information.
    class ServerInformationCallbackProxy
      attr_reader :server_name, :port, :site_addresses, :listeners

      def initialize(server_information)
        @listeners = ServerUrl.new(
          hosts: server_information.listeners,
          port: server_information.port,
          https: server_information.https?,
          format_output: false
        ).to_bind_addresses

        @port           = server_information.port
        @server_name    = server_information.server_name.dup unless server_information.server_name.nil?

        @site_addresses = ServerUrl.new(
          hosts: server_information.site_addresses,
          port: server_information.port,
          https: server_information.https?,
          format_output: false
        ).to_urls
      end
    end
  end
end
