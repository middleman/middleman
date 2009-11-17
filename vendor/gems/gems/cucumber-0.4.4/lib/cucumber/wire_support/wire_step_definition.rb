module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id, @connection = id, connection
      end
      
      def invoke(args)
        @connection.invoke(@id, args)
      end

      def regexp_source
        "/FIXME/"
      end

      def file_colon_line
        "FIXME:0"
      end
    end
  end
end