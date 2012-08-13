require "less"

module Middleman
  module Renderers

    # Sass renderer
    module Less

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Default sass options
          app.set :less, {}

          app.before_configuration do
            template_extensions :less => :css
          end

          app.after_configuration do
            ::Less.paths << File.expand_path(css_dir, source_dir)
          end

          # Tell Tilt to use it as well (for inline sass blocks)
          ::Tilt.register 'less', LocalLoadingLessTemplate
          ::Tilt.prefer(LocalLoadingLessTemplate)
        end

        alias :included :registered
      end

      # A SassTemplate for Tilt which outputs debug messages
      class LocalLoadingLessTemplate < ::Tilt::LessTemplate

        def prepare
          if ::Less.const_defined? :Engine
            @engine = ::Less::Engine.new(data)
          else
            parser  = ::Less::Parser.new(options.merge :filename => eval_file, :line => line, :paths => [".", File.dirname(eval_file)])
            @engine = parser.parse(data)
          end
        end

      end

    end
  end
end
