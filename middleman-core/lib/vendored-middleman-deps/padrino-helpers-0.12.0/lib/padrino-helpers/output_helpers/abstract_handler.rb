module Padrino
  module Helpers
    module OutputHelpers
      class AbstractHandler
        attr_reader :template, :output_buffer

        def initialize(template)
          @template = template
          @output_buffer = template.instance_variable_get(:@_out_buf)
        end

        ##
        # Returns true if the block given is of the handler's template type; false otherwise.
        #
        # @example
        #   @handler.engine_matches?(block) => true
        #
        def engine_matches?(block)
        end

        ##
        # Captures the html from a block of template code for this handler.
        #
        # This method is called to capture content of a block-loving helpers in templates.
        # Haml has a special method to do this, for Erb and Slim we save original buffer,
        # call the block and then restore the buffer.
        #
        # @example
        #   @handler.capture_from_template(&block) => "...html..."
        #
        def capture_from_template(*args, &block)
          self.output_buffer, _buf_was = ActiveSupport::SafeBuffer.new, self.output_buffer
          raw = block.call(*args)
          captured = template.instance_variable_get(:@_out_buf)
          self.output_buffer = _buf_was
          engine_matches?(block) ? captured : raw
        end

        ##
        # Outputs the given text to the template.
        #
        # This method is called when template uses block-aware helpers. For Slim and Haml such
        # helpers just return output to use with `=`. For Erb this method is implemented in
        # ErbHandler by concatenating given text to output buffer.
        #
        # @example
        #   @handler.concat_to_template("This will be output to the template buffer")
        #
        def concat_to_template(text="")
          text
        end

        protected

        def output_buffer=(val)
          template.instance_variable_set(:@_out_buf, val)
        end
      end
    end
  end
end
