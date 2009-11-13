require 'test/xref_test_case'

class TestRDocConstant < XrefTestCase

  def setup
    super

    @const = @c1.constants.first
  end

  def test_path
    assert_equal 'C1.html#CONST', @const.path
  end

end
