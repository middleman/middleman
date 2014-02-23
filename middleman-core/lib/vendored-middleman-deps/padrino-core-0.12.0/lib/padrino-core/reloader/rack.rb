module Padrino
  module Reloader
    ##
    # This class acts as a Rack middleware to be added to the application stack.
    # This middleware performs a check and reload for source files at the start
    # of each request, but also respects a specified cool down time
    # during which no further action will be taken.
    #
    class Rack
      def initialize(app, cooldown=1)
        @app = app
        @cooldown = cooldown
        @last = (Time.now - cooldown)
      end

      # Invoked in order to perform the reload as part of the request stack.
      def call(env)
        if @cooldown && Time.now > @last + @cooldown
          Thread.list.size > 1 ? Thread.exclusive { Padrino.reload! } : Padrino.reload!
          @last = Time.now
        end
        @app.call(env)
      end
    end
  end
end
