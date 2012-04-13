module Padrino
  module Helpers
    module OutputHelpers
      ##
      # Returns the list of all available template handlers
      #
      # @example
      #   OutputHelpers.handlers => [<OutputHelpers::HamlHandler>, <OutputHelpers::ErbHandler>]
      #
      # @private
      def self.handlers
        @_template_handlers ||= []
      end

      ##
      # Registers a new handler as available to the output helpers
      #
      # @example
      #   OutputHelpers.register(OutputHelpers::HamlHandler)
      #
      # @private
      def self.register(handler)
        handlers << handler
      end

      # @abstract Extend this to create a template handler
      class AbstractHandler
        attr_reader :template

        def initialize(template)
          @template = template
        end

        ##
        # Returns extension of the template
        #
        # @example
        #   @handler.template_extension => "erb"
        #
        def template_extension
          caller.find { |c| c =~ /\/views\// }[/\.([\w]*?)\:/, 1] rescue nil
          # "/some/path/app/views/posts/foo.html.erb:3:in `evaluate_source'"
          # => "erb"
        end

        ##
        # Returns an array of engines used for the template
        #
        # @example
        #   @handler.engines => [:erb, :erubis]
        #
        def engines
          # Implemented in subclass
        end

        ##
        # Returns true if the current template type is same as this handlers; false otherwise.
        #
        # @example
        #   @handler.is_type? => true
        #
        def is_type?
          # Implemented in subclass
        end

        ##
        # Returns true if the block given is of the handler's template type; false otherwise.
        #
        # @example
        #   @handler.block_is_type?(block) => true
        #
        def block_is_type?(block)
          # Implemented in subclass
        end

        ##
        # Captures the html from a block of template code for this handler
        #
        # @example
        #   @handler.capture_from_template(&block) => "...html..."
        #
        def capture_from_template(*args, &block)
          # Implemented in subclass
        end

        ##
        # Outputs the given text to the templates buffer directly
        #
        # @example
        #   @handler.concat_to_template("This will be output to the template buffer")
        #
        def concat_to_template(text="")
          # Implemented in subclass
        end
      end # AbstractHandler
    end # OutputHelpers
  end # Helpers
end # Padrino
