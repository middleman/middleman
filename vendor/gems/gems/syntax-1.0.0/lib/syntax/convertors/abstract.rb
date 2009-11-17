require 'syntax'

module Syntax
  module Convertors

    # The abstract ancestor class for all convertors. It implements a few
    # convenience methods to provide a common interface for all convertors.
    class Abstract

      # A reference to the tokenizer used by this convertor.
      attr_reader :tokenizer

      # A convenience method for instantiating a new convertor for a
      # specific syntax.
      def self.for_syntax( syntax )
        new( Syntax.load( syntax ) )
      end

      # Creates a new convertor that uses the given tokenizer.
      def initialize( tokenizer )
        @tokenizer = tokenizer
      end

    end

  end
end
