require 'rubygems'
require 'minitest/unit'
require 'test/xref_test_case'

class TestRDocContext < XrefTestCase

  def setup
    super

    @context = RDoc::Context.new
  end

  def test_initialize
    assert_empty @context.in_files
    assert_equal 'unknown', @context.name
    assert_equal '', @context.comment
    assert_equal nil, @context.parent
    assert_equal :public, @context.visibility
    assert_equal 1, @context.sections.length

    assert_empty @context.classes_hash
    assert_empty @context.modules_hash

    assert_empty @context.method_list
    assert_empty @context.attributes
    assert_empty @context.aliases
    assert_empty @context.requires
    assert_empty @context.includes
    assert_empty @context.constants
  end

  def test_add_alias
    as = RDoc::Alias.new nil, 'old_name', 'new_name', 'comment'

    @context.add_alias as

    assert_equal [as], @context.aliases
    assert_equal [as], @context.unmatched_alias_lists['old_name']
  end

  def test_add_alias_method
    meth = RDoc::AnyMethod.new nil, 'old_name'
    as = RDoc::Alias.new nil, 'old_name', 'new_name', 'comment'
    as.parent = @context

    @context.add_method meth
    @context.add_alias as

    assert_empty @context.aliases
    assert_empty @context.unmatched_alias_lists
    assert_equal %w[old_name new_name], @context.method_list.map { |m| m.name }
  end

  def test_add_class
    @c1.add_class RDoc::NormalClass, 'Klass', 'Object'

    assert_includes @c1.classes.map { |k| k.full_name }, 'C1::Klass'
    assert_includes RDoc::TopLevel.classes.map { |k| k.full_name }, 'C1::Klass'
  end

  def test_add_class_upgrade
    @c1.add_module RDoc::NormalModule, 'Klass'
    @c1.add_class RDoc::NormalClass, 'Klass', nil

    assert_includes @c1.classes.map { |k| k.full_name }, 'C1::Klass',
                    'c1 classes'
    refute_includes @c1.modules.map { |k| k.full_name }, 'C1::Klass',
                    'c1 modules'

    assert_includes RDoc::TopLevel.classes.map { |k| k.full_name }, 'C1::Klass',
                    'TopLevel classes'
    refute_includes RDoc::TopLevel.modules.map { |k| k.full_name }, 'C1::Klass',
                    'TopLevel modules'
  end

  def test_add_constant
    const = RDoc::Constant.new 'NAME', 'value', 'comment'
    @context.add_constant const

    assert_equal [const], @context.constants
  end

  def test_add_include
    incl = RDoc::Include.new 'Name', 'comment'
    @context.add_include incl

    assert_equal [incl], @context.includes
  end

  def test_add_method
    meth = RDoc::AnyMethod.new nil, 'old_name'
    meth.visibility = nil

    @context.add_method meth

    assert_equal [meth], @context.method_list
    assert_equal :public, meth.visibility
  end

  def test_add_method_alias
    as = RDoc::Alias.new nil, 'old_name', 'new_name', 'comment'
    meth = RDoc::AnyMethod.new nil, 'old_name'

    @context.add_alias as
    refute_empty @context.aliases

    @context.add_method meth

    assert_empty @context.aliases
    assert_empty @context.unmatched_alias_lists
    assert_equal %w[old_name new_name], @context.method_list.map { |m| m.name }
  end

  def test_add_module
    @c1.add_module RDoc::NormalModule, 'Mod'

    assert_includes @c1.modules.map { |m| m.full_name }, 'C1::Mod'
  end

  def test_add_module_class
    k = @c1.add_class RDoc::NormalClass, 'Klass', nil
    m = @c1.add_module RDoc::NormalModule, 'Klass'

    assert_equal k, m, 'returns class'
    assert_empty @c1.modules
  end

  def test_add_require
    req = RDoc::Require.new 'require', 'comment'
    @c1.add_require req

    assert_empty @c1.requires
    assert_includes @c1.top_level.requires, req
  end

  def test_add_to
    incl = RDoc::Include.new 'Name', 'comment'
    arr = []
    @context.add_to arr, incl

    assert_includes arr, incl
    assert_equal @context, incl.parent
    assert_equal @context.current_section, incl.section
  end

  def test_add_to_no_document_self
    incl = RDoc::Include.new 'Name', 'comment'
    arr = []
    @context.document_self = false
    @context.add_to arr, incl

    refute_includes arr, incl
  end

  def test_add_to_done_documenting
    incl = RDoc::Include.new 'Name', 'comment'
    arr = []
    @context.done_documenting = true
    @context.add_to arr, incl

    refute_includes arr, incl
  end

  def test_classes
    assert_equal %w[C2::C3], @c2.classes.map { |k| k.full_name }
    assert_equal %w[C3::H1 C3::H2], @c3.classes.map { |k| k.full_name }
  end

  def test_defined_in_eh
    assert @c1.defined_in?(@c1.top_level)

    refute @c1.defined_in?(RDoc::TopLevel.new('name.rb'))
  end

  def test_equals2
    assert_equal @c3,    @c3
    refute_equal @c2,    @c3
    refute_equal @c2_c3, @c3
  end

  def test_find_attribute_named
    assert_equal nil,  @c1.find_attribute_named('none')
    assert_equal 'R',  @c1.find_attribute_named('attr').rw
    assert_equal 'R',  @c1.find_attribute_named('attr_reader').rw
    assert_equal 'W',  @c1.find_attribute_named('attr_writer').rw
    assert_equal 'RW', @c1.find_attribute_named('attr_accessor').rw
  end

  def test_find_constant_named
    assert_equal nil,      @c1.find_constant_named('NONE')
    assert_equal ':const', @c1.find_constant_named('CONST').value
  end

  def test_find_enclosing_module_named
    assert_equal nil, @c2_c3.find_enclosing_module_named('NONE')
    assert_equal @c1, @c2_c3.find_enclosing_module_named('C1')
    assert_equal @c2, @c2_c3.find_enclosing_module_named('C2')
  end

  def test_find_file_named
    assert_equal nil,        @c1.find_file_named('nonexistent.rb')
    assert_equal @xref_data, @c1.find_file_named(@file_name)
  end

  def test_find_instance_method_named
    assert_equal nil, @c1.find_instance_method_named('none')

    m = @c1.find_instance_method_named('m')
    assert_instance_of RDoc::AnyMethod, m
    assert_equal false, m.singleton
  end

  def test_find_local_symbol
    assert_equal true,       @c1.find_local_symbol('m').singleton
    assert_equal ':const',   @c1.find_local_symbol('CONST').value
    assert_equal 'R',        @c1.find_local_symbol('attr').rw
    assert_equal @xref_data, @c1.find_local_symbol(@file_name)
    assert_equal @c2_c3,     @c2.find_local_symbol('C3')
  end

  def test_find_method_named
    assert_equal true, @c1.find_method_named('m').singleton
  end

  def test_find_module_named
    assert_equal @c2_c3, @c2.find_module_named('C3')
    assert_equal @c2,    @c2.find_module_named('C2')
    assert_equal @c1,    @c2.find_module_named('C1')

    assert_equal 'C2::C3', @c2.find_module_named('C3').full_name
  end

  def test_find_symbol
    c3 = @xref_data.find_module_named('C3')
    assert_equal c3,     @xref_data.find_symbol('C3')
    assert_equal c3,     @c2.find_symbol('::C3')
    assert_equal @c2_c3, @c2.find_symbol('C3')
  end

  def test_spaceship
    assert_equal(-1, @c2.<=>(@c3))
    assert_equal 0,  @c2.<=>(@c2)
    assert_equal 1,  @c3.<=>(@c2)

    assert_equal 1,  @c2_c3.<=>(@c2)
    assert_equal(-1, @c2_c3.<=>(@c3))
  end

end

