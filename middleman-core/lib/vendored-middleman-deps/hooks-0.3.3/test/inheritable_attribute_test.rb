require 'test_helper'

class HooksTest < MiniTest::Spec
  describe "Hooks.define_hook" do
    subject {
      Class.new(Object) do
        extend Hooks::InheritableAttribute
        inheritable_attr :drinks
      end
    }

    it "provides a reader with empty inherited attributes, already" do
      assert_equal nil, subject.drinks
    end

    it "provides a reader with empty inherited attributes in a derived class" do
      assert_equal nil, Class.new(subject).drinks
      #subject.drinks = true
      #Class.new(subject).drinks # TODO: crashes.
    end

    it "provides an attribute copy in subclasses" do
      subject.drinks = []
      assert subject.drinks.object_id != Class.new(subject).drinks.object_id
    end

    it "provides a writer" do
      subject.drinks = [:cabernet]
      assert_equal [:cabernet], subject.drinks
    end

    it "inherits attributes" do
      subject.drinks = [:cabernet]

      subklass_a = Class.new(subject)
      subklass_a.drinks << :becks

      subklass_b = Class.new(subject)

      assert_equal [:cabernet],         subject.drinks
      assert_equal [:cabernet, :becks], subklass_a.drinks
      assert_equal [:cabernet],         subklass_b.drinks
    end

    it "does not inherit attributes if we set explicitely" do
      subject.drinks = [:cabernet]
      subklass = Class.new(subject)

      subklass.drinks = [:merlot] # we only want merlot explicitely.
      assert_equal [:merlot], subklass.drinks # no :cabernet, here
    end
  end
end
