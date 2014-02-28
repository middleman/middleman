module Padrino
  module Helpers
    ##
    # Helpers related to buffer output for various template engines.
    #
    module OutputHelpers
      def self.included(base)
        base.send(:include, SinatraCurrentEngine) unless base.method_defined?(:current_engine)
      end

      ##
      # Returns the list of all available template handlers.
      #
      def self.handlers
        @_template_handlers ||= {}
      end

      ##
      # Registers a new handler as available to the output helpers.
      #
      def self.register(engine, handler)
        handlers[engine] = handler
      end

      ##
      # Module used to detect the current engine in vanilla Sinatra apps.
      #
      module SinatraCurrentEngine
        attr_reader :current_engine

        def render(engine, *)
          @current_engine, engine_was = engine, @current_engine
          output = super
          @current_engine = engine_was
          output
        end
      end

      ##
      # Captures the html from a block of template code for any available handler.
      #
      # Be aware that trusting the html is up to the caller.
      #
      # @param [Object] *args
      #   Objects yield to the captured block.
      # @param [Proc] &block
      #   Template code to capture as HTML.
      #
      # @return [String] Captured HTML resulting from the block.
      #
      # @example
      #   capture_html(&block) => "...html..."
      #   capture_html(object_for_block, &block) => "...html..."
      #
      # @example
      #   ActiveSupport::SafeBuffer.new + capture_html { "<foo>" }
      #   # => "&lt;foo&gt;"
      #   ActiveSupport::SafeBuffer.new.safe_concat(capture_html { "<foo>" })
      #   # => "<foo>"
      #
      def capture_html(*args, &block)
        if handler = find_proper_handler
          handler.capture_from_template(*args, &block)
        else
          block.call(*args)
        end
      end
      alias :capture :capture_html

      ##
      # Outputs the given text to the templates buffer directly.
      #
      # The output might be subject to escaping, if it is not marked as safe.
      #
      # @param [String, SafeBuffer] text
      #   Text to concatenate to the buffer.
      #
      # @example
      #   concat_content("This will be output to the template buffer")
      #
      def concat_content(text="")
        if handler = find_proper_handler
          handler.concat_to_template(text)
        else
          text
        end
      end
      alias :concat :concat_content

      ##
      # Outputs the given text to the templates buffer directly,
      # assuming that it is safe.
      #
      # @param [String] text
      #   Text to concatenate to the buffer.
      #
      # @example
      #   concat_safe_content("This will be output to the template buffer")
      #
      def concat_safe_content(text="")
        concat_content text.html_safe
      end

      ##
      # Returns true if the block is from a supported template type; false otherwise.
      # Used to determine if html should be returned or concatenated to the view.
      #
      # @param [Block] block
      #   Determine if this block is a view template.
      #
      # @example
      #   block_is_template?(block) => true
      #
      # @return [Boolean] True if the block is a template; false otherwise.
      #
      def block_is_template?(block)
        handler = find_proper_handler
        block && handler && handler.engine_matches?(block)
      end

      ##
      # Capture a block or text of content to be rendered at a later time.
      # Your blocks can also receive values, which are passed to them by <tt>yield_content</tt>.
      #
      # @overload content_for(key, content)
      #   @param [Symbol] key      Name of your key for the content yield.
      #   @param [String] content  Text to be stored for this key.
      # @overload content_for(key, &block)
      #   @param [Symbol] key      Name of your key for the content yield.
      #   @param [Proc]   block    Block to be stored as content for this key.
      #
      # @example
      #   content_for(:name) { ...content... }
      #   content_for(:name) { |name| ...content... }
      #   content_for(:name, "I'm Jeff")
      #
      def content_for(key, content = nil, options = {}, &block)
        options = content if content.is_a?(Hash)
        content_blocks[key.to_sym].clear if options[:flush]
        content_blocks[key.to_sym] << (block_given? ? block : Proc.new { content })
      end

      ##
      # Is there a content block for a given key?
      #
      # @param [Symbol] key
      #   Name of content to yield.
      #
      # @return [TrueClass,FalseClass] Result html for the given +key+
      #
      # @example
      #   content_for? :header => true
      #
      def content_for?(key)
        content_blocks[key.to_sym].present?
      end

      ##
      # Render the captured content blocks for a given key.
      # You can also pass values to the content blocks by passing them
      # as arguments after the key.
      #
      # @param [Symbol] key
      #   Name of content to yield.
      # @param *args
      #   Values to pass to the content block.
      #
      # @return [String] Result HTML for the given +key+.
      #
      # @example
      #   yield_content :include
      #   yield_content :head, "param1", "param2"
      #   yield_content(:title) || "My page title"
      #
      def yield_content(key, *args)
        blocks = content_blocks[key.to_sym]
        return nil if blocks.empty?
        mark_safe(blocks.map { |content| capture_html(*args, &content) }.join)
      end

      protected
      ##
      # Retrieves content_blocks stored by content_for or within yield_content.
      #
      # @example
      #   content_blocks[:name] => ['...', '...']
      #
      def content_blocks
        @content_blocks ||= Hash.new { |h,k| h[k] = [] }
      end

      ##
      # Retrieves the template handler for the given output context.
      # Can handle any output related to capturing or concatenating in a given template.
      #
      # @example
      #   find_proper_handler => <OutputHelpers::HamlHandler>
      #
      def find_proper_handler
        handler_class = OutputHelpers.handlers[current_engine]
        handler_class && handler_class.new(self)
      end

      ##
      # Marks a String or a collection of Strings as safe. `nil` is accepted
      # but ignored.
      #
      # @param [String, Array<String>] the values to be marked safe.
      #
      # @return [ActiveSupport::SafeBuffer, Array<ActiveSupport::SafeBuffer>]
      def mark_safe(value)
        if value.respond_to? :map!
          value.map!{|v| v.html_safe if v }
        else
          value.html_safe if value
        end
      end
    end
  end
end
