module Padrino
  module Helpers
    module OutputHelpers
      class HamlHandler < AbstractHandler
        ##
        # Returns true if the current template type is same as this handlers; false otherwise.
        #
        # ==== Examples
        #
        #  @handler.is_type? => true
        #
        def is_type?
          template.respond_to?(:is_haml?) && template.is_haml?
        end

        ##
        # Returns true if the block given is of the handler's template type; false otherwise.
        #
        # ==== Examples
        #
        #  @handler.block_is_type?(block) => true
        #
        def block_is_type?(block)
          template.block_is_haml?(block)
        end

        # Captures the html from a block of template code for this handler
        #
        # ==== Examples
        #
        #  @handler.capture_from_template(&block) => "...html..."
        #
        def capture_from_template(*args, &block)
          eval("_hamlout ||= @haml_buffer", block.binding) # this is for rbx
          template.capture_haml(*args, &block)
        end

        ##
        # Outputs the given text to the templates buffer directly
        #
        # ==== Examples
        #
        #   @handler.concat_to_template("This will be output to the template buffer")
        #
        def concat_to_template(text="")
          template.haml_concat(text)
          nil
        end

        ##
        # Returns an array of engines used for the template
        #
        # ==== Examples
        #
        #   @handler.engines => [:erb, :erubis]
        #
        def engines
          @_engines ||= [:haml]
        end
      end # HamlHandler
      OutputHelpers.register(HamlHandler)
    end # OutputHelpers
  end # Helpers
end # Padrino