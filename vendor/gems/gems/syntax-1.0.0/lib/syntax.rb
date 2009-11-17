require 'syntax/common'

module Syntax

  # A default tokenizer for handling syntaxes that are not explicitly handled
  # elsewhere. It simply yields the given text as a single token.
  class Default
    
    # Yield the given text as a single token.
    def tokenize( text )
      yield Token.new( text, :normal )
    end

  end

  # A hash for registering syntax implementations.
  SYNTAX = Hash.new( Default )

  # Load the implementation of the requested syntax. If the syntax cannot be
  # found, or if it cannot be loaded for whatever reason, the Default syntax
  # handler will be returned.
  def load( syntax )
    begin
      require "syntax/lang/#{syntax}"
    rescue LoadError
    end
    SYNTAX[ syntax ].new
  end
  module_function :load

  # Return an array of the names of supported syntaxes.
  def all
    lang_dir = File.join(File.dirname(__FILE__), "syntax", "lang")
    Dir["#{lang_dir}/*.rb"].map { |path| File.basename(path, ".rb") }
  end
  module_function :all

end
