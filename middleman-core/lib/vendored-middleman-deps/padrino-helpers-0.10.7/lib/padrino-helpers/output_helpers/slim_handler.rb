# Make slim works with sinatra/padrino
Slim::Engine.set_default_options(:buffer => '@_out_buf', :generator => Temple::Generators::StringBuffer) if defined?(Slim)

module Padrino
  module Helpers
    module OutputHelpers
      ##
      # Handler for reading and writing from a slim template.
      #
      class SlimHandler < AbstractHandler
        attr_reader :output_buffer

        def initialize(template)
          super
          @output_buffer = template.instance_variable_get(:@_out_buf)
        end

        ##
        # Returns true if the current template type is same as this handlers; false otherwise.
        #
        # @example
        #   @handler.is_type? => true
        #
        def is_type?
          !self.output_buffer.nil?
        end

        # Captures the html from a block of template code for this handler
        #
        # @example
        #   @handler.capture_from_template(&block) => "...html..."
        #
        def capture_from_template(*args, &block)
          self.output_buffer, _buf_was = '', self.output_buffer
          block.call(*args)
          ret = eval('@_out_buf', block.binding)
          self.output_buffer = _buf_was
          ret
        end

        ##
        # Outputs the given text to the templates buffer directly
        #
        # @example
        #   @handler.concat_to_template("This will be output to the template buffer")
        #
        def concat_to_template(text="")
          self.output_buffer << text if is_type? && text
          nil
        end

        ##
        # Returns true if the block given is of the handler's template type; false otherwise.
        #
        # @example
        #   @handler.block_is_type?(block) => true
        #
        def block_is_type?(block)
          is_type? || (block && eval('defined? __in_erb_template', block.binding))
        end

        ##
        # Returns an array of engines used for the template
        #
        # @example
        #   @handler.engines => [:erb, :erubis]
        #
        def engines
          @_engines ||= [:slim]
        end

        protected
          def output_buffer=(val)
            template.instance_variable_set(:@_out_buf, val)
          end
        end # SlimHandler

        OutputHelpers.register(SlimHandler)
    end # OutputHelpers
  end # Helpers
end # Padrino
