require 'strscan'

module Syntax

  # A single token extracted by a tokenizer. It is simply the lexeme
  # itself, decorated with a 'group' attribute to identify the type of the
  # lexeme.
  class Token < String

    # the type of the lexeme that was extracted.
    attr_reader :group

    # the instruction associated with this token (:none, :region_open, or
    # :region_close)
    attr_reader :instruction

    # Create a new Token representing the given text, and belonging to the
    # given group.
    def initialize( text, group, instruction = :none )
      super text
      @group = group
      @instruction = instruction
    end

  end

  # The base class of all tokenizers. It sets up the scanner and manages the
  # looping until all tokens have been extracted. It also provides convenience
  # methods to make sure adjacent tokens of identical groups are returned as
  # a single token.
  class Tokenizer

    # The current group being processed by the tokenizer
    attr_reader :group

    # The current chunk of text being accumulated
    attr_reader :chunk

    # Start tokenizing. This sets up the state in preparation for tokenization,
    # such as creating a new scanner for the text and saving the callback block.
    # The block will be invoked for each token extracted.
    def start( text, &block )
      @chunk = ""
      @group = :normal
      @callback = block
      @text = StringScanner.new( text )
      setup
    end

    # Subclasses may override this method to provide implementation-specific
    # setup logic.
    def setup
    end

    # Finish tokenizing. This flushes the buffer, yielding any remaining text
    # to the client.
    def finish
      start_group nil
      teardown
    end

    # Subclasses may override this method to provide implementation-specific
    # teardown logic.
    def teardown
    end

    # Subclasses must implement this method, which is called for each iteration
    # of the tokenization process. This method may extract multiple tokens.
    def step
      raise NotImplementedError, "subclasses must implement #step"
    end

    # Begins tokenizing the given text, calling #step until the text has been
    # exhausted.
    def tokenize( text, &block )
      start text, &block
      step until @text.eos?
      finish
    end

    # Specify a set of tokenizer-specific options. Each tokenizer may (or may
    # not) publish any options, but if a tokenizer does those options may be
    # used to specify optional behavior.
    def set( opts={} )
      ( @options ||= Hash.new ).update opts
    end

    # Get the value of the specified option.
    def option(opt)
      @options ? @options[opt] : nil
    end

    private

      EOL = /(?=\r\n?|\n|$)/

      # A convenience for delegating method calls to the scanner.
      def self.delegate( sym )
        define_method( sym ) { |*a| @text.__send__( sym, *a ) }
      end

      delegate :bol?
      delegate :eos?
      delegate :scan
      delegate :scan_until
      delegate :check
      delegate :check_until
      delegate :getch
      delegate :matched
      delegate :pre_match
      delegate :peek
      delegate :pos

      # Access the n-th subgroup from the most recent match.
      def subgroup(n)
        @text[n]
      end

      # Append the given data to the currently active chunk.
      def append( data )
        @chunk << data
      end

      # Request that a new group be started. If the current group is the same
      # as the group being requested, a new group will not be created. If a new
      # group is created and the current chunk is not empty, the chunk's
      # contents will be yielded to the client as a token, and then cleared.
      #
      # After the new group is started, if +data+ is non-nil it will be appended
      # to the chunk.
      def start_group( gr, data=nil )
        flush_chunk if gr != @group
        @group = gr
        @chunk << data if data
      end

      def start_region( gr, data=nil )
        flush_chunk
        @group = gr
        @callback.call( Token.new( data||"", @group, :region_open ) )
      end

      def end_region( gr, data=nil )
        flush_chunk
        @group = gr
        @callback.call( Token.new( data||"", @group, :region_close ) )
      end

      def flush_chunk
        @callback.call( Token.new( @chunk, @group ) ) unless @chunk.empty?
        @chunk = ""
      end

      def subtokenize( syntax, text )
        tokenizer = Syntax.load( syntax )
        tokenizer.set @options if @options
        flush_chunk
        tokenizer.tokenize( text, &@callback )
      end

  end

end
