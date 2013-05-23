require 'test_helper'

class HooksTest < Test::Unit::TestCase
  context "Hooks.define_hook" do
    setup do
      @klass = Class.new(Object) do
        extend Hooks::InheritableAttribute
      end

      @mum = @klass.new
      @klass.inheritable_attr :drinks
    end

    should "provide a reader with empty inherited attributes, already" do
      assert_equal nil, @klass.drinks
    end

    should "provide a reader with empty inherited attributes in a derived class" do
      assert_equal nil, Class.new(@klass).drinks
      #@klass.drinks = true
      #Class.new(@klass).drinks # TODO: crashes.
    end

    should "provide an attribute copy in subclasses" do
      @klass.drinks = []
      assert @klass.drinks.object_id != Class.new(@klass).drinks.object_id
    end

    should "provide a writer" do
      @klass.drinks = [:cabernet]
      assert_equal [:cabernet], @klass.drinks
    end

    should "inherit attributes" do
      @klass.drinks = [:cabernet]

      subklass_a = Class.new(@klass)
      subklass_a.drinks << :becks

      subklass_b = Class.new(@klass)

      assert_equal [:cabernet],         @klass.drinks
      assert_equal [:cabernet, :becks], subklass_a.drinks
      assert_equal [:cabernet],         subklass_b.drinks
    end

    should "not inherit attributes if we set explicitely" do
      @klass.drinks = [:cabernet]
      subklass = Class.new(@klass)

      subklass.drinks = [:merlot] # we only want merlot explicitely.
      assert_equal [:merlot], subklass.drinks # no :cabernet, here
    end
  end
end
