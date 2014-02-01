require "test_helper"

class InstanceHooksTest < HooksTest
  describe "#define_hook" do
    let(:klass) { Class.new(TestClass) do
      include Hooks::InstanceHooks
    end }

    subject { klass.new.tap do |obj|
      obj.instance_eval do
        def dine; executed << :dine; end
      end
    end }

    it "adds hook to instance" do
      subject.define_hook :after_eight

      assert_equal [], subject.callbacks_for_hook(:after_eight)
    end

    it "copies existing class hook" do
      klass.define_hook :after_eight
      klass.after_eight :dine

      assert_equal [:dine], subject.callbacks_for_hook(:after_eight)
    end

    describe "#after_eight (adding callbacks)" do
      before do
        subject.define_hook :after_eight
        subject.after_eight :dine
      end

      it "adds #after_eight hook" do
        assert_equal [:dine], subject.callbacks_for_hook(:after_eight)
      end

      it "responds to #run_hook" do
        subject.run_hook :after_eight
        subject.executed.must_equal [:dine]
      end
    end

    describe "#after_eight from class (no define_hook in instance)" do
      it "responds to #after_eight" do
        klass.define_hook :after_eight

        subject.after_eight :dine

        subject.run_hook :after_eight
        subject.executed.must_equal [:dine]
      end
    end
  end
end