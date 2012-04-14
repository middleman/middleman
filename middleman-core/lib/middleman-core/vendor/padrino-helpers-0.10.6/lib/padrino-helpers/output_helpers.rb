module Padrino
  module Helpers
    ###
    # Helpers related to buffer output for various template engines.
    #
    module OutputHelpers

      def self.included(base) # @private
        base.send(:include, SinatraCurrentEngine) unless base.method_defined?(:current_engine)
      end

      ##
      # Module used to detect the current engine in vanilla sinatra apps.
      # @private
      module SinatraCurrentEngine
        attr_reader :current_engine

        def render(engine, *) # @private
          @current_engine, engine_was = engine, @current_engine
          output = super
          @current_engine = engine_was
          output
        end
      end

      ##
      # Captures the html from a block of template code for any available handler.
      #
      # @param [Object] *args
      #   Objects yield to the captured block
      # @param [Proc] &block
      #   Template code to capture as html
      #
      # @return [String] Captured html resulting from the block
      #
      # @example
      #   capture_html(&block) => "...html..."
      #   capture_html(object_for_block, &block) => "...html..."
      #
      # @api semipublic
      def capture_html(*args, &block)
        handler = find_proper_handler
        captured_html = ""
        if handler && handler.is_type? && handler.block_is_type?(block)
          captured_html = handler.capture_from_template(*args, &block)
        end
        # invoking the block directly if there was no template
        captured_html = block_given? && block.call(*args) if captured_html.blank?
        captured_html
      end
      alias :capture :capture_html

      ##
      # Outputs the given text to the templates buffer directly.
      #
      # @param [String] text
      #   Text to concatenate to the buffer.
      #
      # @example
      #   concat_content("This will be output to the template buffer")
      #
      # @api semipublic
      def concat_content(text="")
        handler = find_proper_handler
        if handler && handler.is_type?
          handler.concat_to_template(text)
        else # theres no template to concat, return the text directly
          text
        end
      end
      alias :concat :concat_content

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
      # @api semipublic
      def block_is_template?(block)
        handler = find_proper_handler
        block && handler && handler.block_is_type?(block)
      end

      ##
      # Capture a block or text of content to be rendered at a later time.
      # Your blocks can also receive values, which are passed to them by <tt>yield_content</tt>
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
      # @api public
      def content_for(key, content = nil, &block)
        content_blocks[key.to_sym] << (block_given? ? block : Proc.new { content })
      end

      ##
      # Is there a content block for a given key?
      #
      # @param [Symbol] key
      #   Name of content to yield
      #
      # @return [TrueClass,FalseClass] Result html for the given +key+
      #
      # @example
      #   content_for? :header => true
      #
      # @api public
      def content_for?(key)
        content_blocks[key.to_sym].present?
      end

      ##
      # Render the captured content blocks for a given key.
      # You can also pass values to the content blocks by passing them
      # as arguments after the key.
      #
      # @param [Symbol] key
      #   Name of content to yield
      # @param *args
      #   Values to pass to the content block
      #
      # @return [String] Result html for the given +key+
      #
      # @example
      #   yield_content :include
      #   yield_content :head, "param1", "param2"
      #   yield_content(:title) || "My page title"
      #
      # @api public
      def yield_content(key, *args)
        blocks = content_blocks[key.to_sym]
        return nil if blocks.empty?
        blocks.map { |content| capture_html(*args, &content) }.join
      end

      protected
        ##
        # Retrieves content_blocks stored by content_for or within yield_content
        #
        # @example
        #   content_blocks[:name] => ['...', '...']
        #
        def content_blocks
          @content_blocks ||= Hash.new { |h,k| h[k] = [] }
        end

        ##
        # Retrieves the template handler for the given output context.
        # Can handle any output related to capturing or concating in a given template.
        #
        # @example
        #   find_proper_handler => <OutputHelpers::HamlHandler>
        #
        def find_proper_handler
          OutputHelpers.handlers.map { |h| h.new(self) }.find { |h| h.engines.include?(current_engine) && h.is_type? }
        end
    end # OutputHelpers
  end # Helpers
end # Padrino
