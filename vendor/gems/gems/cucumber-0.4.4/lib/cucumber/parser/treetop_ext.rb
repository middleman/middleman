begin
  require 'treetop'
  require 'treetop/runtime'
  require 'treetop/ruby_extensions'
rescue LoadError
  require "rubygems"
  gem "treetop"
  require 'treetop'
  require 'treetop/runtime'
  require 'treetop/ruby_extensions'
end

module Cucumber
  module Parser
    # Raised if Cucumber fails to parse a feature file
    class SyntaxError < StandardError
      def initialize(parser, file, line_offset)
        tf = parser.terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        line = parser.failure_line + line_offset
        message = "#{file}:#{line}:#{parser.failure_column}: Parse error, expected #{expected}."
        super(message)
      end
    end
    
    module TreetopExt #:nodoc:
      def parse_or_fail(source, file=nil, filter=nil, line_offset=0)
        parse_tree = parse(source)
        if parse_tree.nil?
          raise Cucumber::Parser::SyntaxError.new(self, file, line_offset)
        else
          ast = parse_tree.build(filter) # may return nil if it doesn't match filter.
          ast.file = file unless ast.nil?
          ast
        end
      end
    end
  end
end

module Treetop #:nodoc:
  module Runtime #:nodoc:
    class SyntaxNode #:nodoc:
      def line
        input.line_of(interval.first)
      end
    end

    class CompiledParser #:nodoc:
      include Cucumber::Parser::TreetopExt
    end
  end
end
