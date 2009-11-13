require 'test/xref_test_case'

class RDocAnyMethodTest < XrefTestCase

  def test_full_name
    assert_equal 'C1::m', @c1.method_list.first.full_name
  end

end

