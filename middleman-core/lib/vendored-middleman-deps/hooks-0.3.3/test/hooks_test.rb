require 'test_helper'

class HooksTest < MiniTest::Spec
  class TestClass
    include Hooks

    def executed
      @executed ||= [];
    end
  end


  describe "::define_hook" do
    let(:klass) do
      Class.new(TestClass) do
        define_hook :after_eight
      end
    end

    subject { klass.new }

    it "respond to Class.callbacks_for_hook" do
      assert_equal [], klass.callbacks_for_hook(:after_eight)
      klass.after_eight :dine
      assert_equal [:dine], klass.callbacks_for_hook(:after_eight)
    end

    it 'symbolizes strings when defining a hook' do
      subject.class.define_hooks :before_one, 'after_one'
      assert_equal [], klass.callbacks_for_hook(:before_one)
      assert_equal [], klass.callbacks_for_hook(:after_one)
      assert_equal [], klass.callbacks_for_hook('after_one')
    end

    it "accept multiple hook names" do
      subject.class.define_hooks :before_ten, :after_ten
      assert_equal [], klass.callbacks_for_hook(:before_ten)
      assert_equal [], klass.callbacks_for_hook(:after_ten)
    end

    describe "creates a public writer for the hook that" do
      it "accepts method names" do
        klass.after_eight :dine
        assert_equal [:dine], klass._hooks[:after_eight]
      end

      it "accepts blocks" do
        klass.after_eight do true; end
        assert klass._hooks[:after_eight].first.kind_of? Proc
      end

      it "be inherited" do
        klass.after_eight :dine
        subklass = Class.new(klass)

        assert_equal [:dine], subklass._hooks[:after_eight]
      end
      # TODO: check if options are not shared!
    end

    describe "Hooks#run_hook" do
      it "run without parameters" do
        subject.instance_eval do
          def a; executed << :a; nil; end
          def b; executed << :b; end

          self.class.after_eight :b
          self.class.after_eight :a
        end

        subject.run_hook(:after_eight)

        assert_equal [:b, :a], subject.executed
      end

      it "returns empty Results when no callbacks defined" do
        subject.run_hook(:after_eight).must_equal Hooks::Hook::Results.new
      end

      it "accept arbitrary parameters" do
        subject.instance_eval do
          def a(me, arg); executed << arg+1; end
        end
        subject.class.after_eight :a
        subject.class.after_eight lambda { |me, arg| me.executed << arg-1 }

        subject.run_hook(:after_eight, subject, 1)

        assert_equal [2, 0], subject.executed
      end

      it "execute block callbacks in instance context" do
        subject.class.after_eight { executed << :c }
        subject.run_hook(:after_eight)
        assert_equal [:c], subject.executed
      end

      it "returns all callbacks in order" do
        subject.class.after_eight { :dinner_out }
        subject.class.after_eight { :party_hard }
        subject.class.after_eight { :taxi_home }

        results = subject.run_hook(:after_eight)

        assert_equal [:dinner_out, :party_hard, :taxi_home], results
        assert_equal false, results.halted?
        assert_equal true, results.not_halted?
      end

      describe "halts_on_falsey: true" do
        let(:klass) do
          Class.new(TestClass) do
            define_hook :after_eight, :halts_on_falsey => true
          end
        end

        [nil, false].each do |falsey|
          it "returns successful callbacks in order (with #{falsey.inspect})" do
            ordered = []

            subject.class.after_eight { :dinner_out }
            subject.class.after_eight { :party_hard; falsey }
            subject.class.after_eight { :taxi_home }

            results = subject.run_hook(:after_eight)

            assert_equal [:dinner_out], results
            assert_equal true, results.halted?
          end
        end
      end

      describe "halts_on_falsey: false" do
        [nil, false].each do |falsey|
          it "returns all callbacks in order (with #{falsey.inspect})" do
            ordered = []

            subject.class.after_eight { :dinner_out }
            subject.class.after_eight { :party_hard; falsey }
            subject.class.after_eight { :taxi_home }

            results = subject.run_hook(:after_eight)

            assert_equal [:dinner_out, falsey, :taxi_home], results
            assert_equal false, results.halted?
          end
        end
      end
    end

    describe "in class context" do
      it "runs callback block" do
        executed = []
        klass.after_eight do
          executed << :klass
        end
        klass.run_hook(:after_eight)

        executed.must_equal([:klass])
      end

      it "runs instance methods" do
        executed = []
        klass.instance_eval do
          after_eight :have_dinner

          def have_dinner(executed)
            executed << :have_dinner
          end
        end
        klass.run_hook(:after_eight, executed)

        executed.must_equal([:have_dinner])
      end
    end
  end

  describe "Inheritance" do
    let (:superclass) {
      Class.new(TestClass) do
        define_hook :after_eight

        after_eight :take_shower
      end
    }

    let (:subclass) { Class.new(superclass) do after_eight :have_dinner end }

    it "inherits callbacks from the hook" do
      subclass.callbacks_for_hook(:after_eight).must_equal [:take_shower, :have_dinner]
    end

    it "doesn't mix up superclass hooks" do
      subclass.superclass.callbacks_for_hook(:after_eight).must_equal [:take_shower]
    end
  end
end

class HookSetTest < MiniTest::Spec
  subject { Hooks::HookSet.new }

  let (:first_hook)   { Hooks::Hook.new(:halts_on_falsey => true) }
  let (:second_hook)  { Hooks::Hook.new(:halts_on_falsey => false) }

  it "responds to #clone" do
    subject[:after_eight] = [first_hook]

    clone = subject.clone

    clone[:after_eight] << second_hook

    subject.must_equal(:after_eight => [first_hook])
    clone.must_equal(:after_eight => [first_hook, second_hook])
  end
  # TODO: test if options get cloned.
end