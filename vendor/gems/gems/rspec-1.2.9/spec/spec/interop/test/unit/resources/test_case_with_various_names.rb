rspec_lib = File.dirname(__FILE__) + "/../../../../../../lib"
$:.unshift rspec_lib unless $:.include?(rspec_lib)
require 'spec/autorun'
require 'spec/test/unit'

class TestCaseThatPasses < Test::Unit::TestCase
  def test_should_allow_underscore
    assert true
  end

  def testShouldAllowUppercaseLetter
    assert true
  end

  def testshouldallowlowercaseletter
    assert true
  end

  define_method :"test: should allow punctuation" do
    assert true
  end
end
