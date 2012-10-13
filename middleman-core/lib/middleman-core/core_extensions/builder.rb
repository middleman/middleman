module Middleman
  module CoreExtensions

    # Convenience methods to allow config.rb to talk to the Builder
    module Builder

      # Extension registered
      class << self
        # @private
        def registered(app)
          app.define_hook :after_build
          
          ::Middleman::Extension.add_hooks do
            set_callback :activate, :after, :autoregister_after_build

            def autoregister_after_build
              return unless respond_to?(:after_build)
              app.after_build(&method(:after_build))
            end
          end
        end
        alias :included :registered
      end
    end
  end
end
