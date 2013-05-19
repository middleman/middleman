gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha' # Load mocha after minitest

begin
  require 'ruby-debug'
rescue LoadError; end

class MiniTest::Spec
  class << self
    alias :setup :before unless defined?(Rails)
    alias :teardown :after unless defined?(Rails)
    alias :should :it
    alias :context :describe
    def should_eventually(desc)
      it("should eventually #{desc}") { skip("Should eventually #{desc}") }
    end
  end
  alias :assert_no_match  :refute_match
  alias :assert_not_nil   :refute_nil
  alias :assert_not_equal :refute_equal
end

class ColoredIO
  def initialize(io)
    @io = io
  end

  def print(o)
    case o
    when "." then @io.send(:print, o.green)
    when "E" then @io.send(:print, o.red)
    when "F" then @io.send(:print, o.yellow)
    when "S" then @io.send(:print, o.magenta)
    else @io.send(:print, o)
    end
  end

  def puts(*o)
    super
  end
end

MiniTest::Unit.output = ColoredIO.new(MiniTest::Unit.output)
