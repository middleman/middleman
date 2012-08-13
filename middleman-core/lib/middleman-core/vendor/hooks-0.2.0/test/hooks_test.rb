require 'test_helper'

class HooksTest < Test::Unit::TestCase
  class TestClass
    include Hooks

    def executed
      @executed ||= [];
    end
  end


  context "Hooks.define_hook" do
    setup do
      @klass = Class.new(TestClass)

      @mum = @klass.new
      @mum.class.define_hook :after_eight
    end

    should "provide accessors to the stored callbacks" do
      assert_equal [], @klass._after_eight_callbacks
      @klass._after_eight_callbacks << :dine
      assert_equal [:dine], @klass._after_eight_callbacks
    end

    should "respond to Class.callbacks_for_hook" do
      assert_equal [], @klass.callbacks_for_hook(:after_eight)
      @klass.after_eight :dine
      assert_equal [:dine], @klass.callbacks_for_hook(:after_eight)
    end

    context "creates a public writer for the hook that" do
      should "accepts method names" do
        @klass.after_eight :dine
        assert_equal [:dine], @klass._after_eight_callbacks
      end

      should "accepts blocks" do
        @klass.after_eight do true; end
        assert @klass._after_eight_callbacks.first.kind_of? Proc
      end

      should "be inherited" do
        @klass.after_eight :dine
        subklass = Class.new(@klass)

        assert_equal [:dine], subklass._after_eight_callbacks
      end
    end

    context "Hooks#run_hook" do
      should "run without parameters" do
        @mum.instance_eval do
          def a; executed << :a; nil; end
          def b; executed << :b; end

          self.class.after_eight :b
          self.class.after_eight :a
        end

        @mum.run_hook(:after_eight)

        assert_equal [:b, :a], @mum.executed
      end

      should "accept arbitrary parameters" do
        @mum.instance_eval do
          def a(me, arg); executed << arg+1; end
        end
        @mum.class.after_eight :a
        @mum.class.after_eight lambda { |me, arg| me.executed << arg-1 }

        @mum.run_hook(:after_eight, @mum, 1)

        assert_equal [2, 0], @mum.executed
      end

      should "execute block callbacks in instance context" do
        @mum.class.after_eight { executed << :c }
        @mum.run_hook(:after_eight)
        assert_equal [:c], @mum.executed
      end
    end

    context "in class context" do
      should "run a callback block" do
        executed = []
        @klass.after_eight do
          executed << :klass
        end
        @klass.run_hook :after_eight

        assert_equal [:klass], executed
      end

      should "run a class methods" do
        executed = []
        @klass.instance_eval do
          after_eight :have_dinner

          def have_dinner(executed)
            executed << :have_dinner
          end
        end
        @klass.run_hook :after_eight, executed

        assert_equal [:have_dinner], executed
      end
    end
  end

  context "Deriving" do
    setup do
      @klass = Class.new(TestClass)

      @mum = @klass.new
      @mum.class.define_hook :after_eight
    end

    should "inherit the hook" do
      @klass.class_eval do
        after_eight :take_shower

        def take_shower
          executed << :take_shower
        end
      end

      @kid = Class.new(@klass) do
        after_eight :have_dinner

        def have_dinner
          executed << :have_dinner
        end
      end.new

      assert_equal [:take_shower, :have_dinner], @kid.run_hook(:after_eight)
    end
  end
end
