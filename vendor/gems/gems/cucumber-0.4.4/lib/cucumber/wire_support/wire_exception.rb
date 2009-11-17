module Cucumber
  module WireSupport
    # Proxy for an exception that occured at the remote end of the wire
    class WireException < StandardError
      def initialize(args)
        super args['message']
      end
    end
  end
end