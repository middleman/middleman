$:.unshift File.dirname(__FILE__) + "/../../lib"

require 'test/unit'
require 'syntax'

class TokenizerTestCase < Test::Unit::TestCase
  def self.syntax( type )
    class_eval <<-EOF
      def setup
        @tokenizer = Syntax.load(#{type.inspect})
      end
    EOF
  end

  def default_test
  end

  private

    attr_reader :tokenizer

    def tokenize( string )
      @tokens = []
      @tokenizer.tokenize( string ) { |tok| @tokens << tok }
    end

    def assert_next_token(group, lexeme, instruction=:none)
      assert false, "no tokens in stack" if @tokens.nil? or @tokens.empty?
      assert_equal [group, lexeme, instruction],
        [@tokens.first.group, @tokens.first, @tokens.shift.instruction]
    end

    def assert_no_next_token
      assert @tokens.empty?
    end

    def skip_token( n=1 )
      n.times { @tokens.shift } unless @tokens.nil? || @tokens.empty?
    end
end
