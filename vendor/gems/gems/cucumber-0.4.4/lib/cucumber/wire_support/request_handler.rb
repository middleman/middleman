module Cucumber
  module WireSupport
    class RequestHandler
      def initialize(connection, message, &block)
        @connection = connection
        @message = message
        instance_eval(&block) if block
      end

      def execute(request_params)
        @connection.call_remote(self, @message, request_params)
      end

      def handle_fail(params)
        raise WireException.new(params)
      end
    end
  end
end
