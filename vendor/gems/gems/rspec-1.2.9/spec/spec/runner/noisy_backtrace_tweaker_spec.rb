require 'spec_helper'

module Spec
  module Runner
    describe NoisyBacktraceTweaker do
      before(:each) do
        @error = RuntimeError.new
        @tweaker = NoisyBacktraceTweaker.new
      end

      it "gracefully handles nil backtrace" do
        lambda do
          @tweaker.tweak_backtrace(@error)
        end.should_not raise_error
      end

      it "cleans up double slashes" do
        @error.set_backtrace(["/a//b/c//d.rb"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should include("/a/b/c/d.rb")
      end

      it "preserves lines in lib/spec" do
        ["expectations", "mocks", "runner", "stubs"].each do |child|
          @error.set_backtrace(["/lib/spec/#{child}/anything.rb"])
          @tweaker.tweak_backtrace(@error)
          @error.backtrace.should_not be_empty
        end
      end

      it "preserves lines in spec/" do
        @error.set_backtrace(["/lib/spec/expectations/anything.rb"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should_not be_empty
      end

      it "preserves lines in bin/spec" do
        @error.set_backtrace(["bin/spec:"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should_not be_empty
      end

      it "ignores custom patterns" do
        @tweaker.ignore_patterns(/custom_pattern/)
        @error.set_backtrace(["custom_pattern"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should_not be_empty
      end
    end
  end
end
