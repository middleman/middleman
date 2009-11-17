$:.unshift File.dirname(__FILE__) + "/../lib"
require 'syntax'
require 'test/unit'

class TC_Syntax < Test::Unit::TestCase
  def test_all
    langs = Syntax.all
    assert langs.include?("ruby")
    assert langs.include?("xml")
    assert langs.include?("yaml")
  end

  def test_load_bogus
    lang = Syntax.load "bogus"
    assert_instance_of Syntax::Default, lang
  end

  def test_load
    lang = Syntax.load "ruby"
    assert_instance_of Syntax::Ruby, lang
  end
end
