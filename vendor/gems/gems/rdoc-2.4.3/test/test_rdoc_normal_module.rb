require 'test/xref_test_case'

class TestRDocNormalModule < XrefTestCase

  def setup
    super

    @mod = RDoc::NormalModule.new 'Mod'
  end

  def test_comment_equals
    @mod.comment = '# comment 1'

    assert_equal '# comment 1', @mod.comment

    @mod.comment = '# comment 2'

    assert_equal "# comment 1\n# ---\n# comment 2", @mod.comment
  end

  def test_module_eh
    assert @mod.module?
  end

end

