module Middleman
  module Rack
    class Downstream
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        if env["DOWNSTREAM"]
          env["DOWNSTREAM"]
        else
          @app.call(env)
        end
      end
    end
  end
end