require 'less'

module Middleman
  module Renderers
    # Sass renderer
    class Less < ::Middleman::Extension
      define_setting :less, {}, 'LESS compiler options'

      def initialize(app, options={}, &block)
        super

        # Tell Tilt to use it as well (for inline sass blocks)
        ::Tilt.register 'less', LocalLoadingLessTemplate
        ::Tilt.prefer(LocalLoadingLessTemplate)
      end

      def after_configuration
        app.files.by_type(:source).watchers.each do |source|
          ::Less.paths << (source.directory + app.config[:css_dir]).to_s
        end
      end

      # A SassTemplate for Tilt which outputs debug messages
      class LocalLoadingLessTemplate < ::Tilt::LessTemplate
        def prepare
          if ::Less.const_defined? :Engine
            @engine = ::Less::Engine.new(data)
          else
            parser = ::Less::Parser.new({}.merge!(options).merge!(filename: eval_file, line: line, paths: ['.', File.dirname(eval_file)]))
            @engine = parser.parse(data)
          end
        end
      end
    end
  end
end
