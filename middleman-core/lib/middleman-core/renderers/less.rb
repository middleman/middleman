module Middleman
  module Renderers
    # Sass renderer
    class Less < ::Middleman::Extension
      # A SassTemplate for Tilt which outputs debug messages
      class DummyLessTemplate < ::Tilt::Template
        def evaluate(scope, locals, &block)
          raise <<~ERROR
            The builtin less renderer has been removed from middleman.
            To continue using less, make sure to setup an external pipeline.
            See external pipeline documentation at https://middlemanapp.com/advanced/external-pipeline
            for more information.
          ERROR
        end
      end

      ::Tilt.register 'less', DummyLessTemplate
    end
  end
end
