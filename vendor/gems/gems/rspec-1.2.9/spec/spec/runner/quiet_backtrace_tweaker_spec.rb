require 'spec_helper'

module Spec
  module Runner
    describe QuietBacktraceTweaker do
      before(:each) do
        @error = RuntimeError.new
        @tweaker = QuietBacktraceTweaker.new
      end

      it "gracefully handles nil backtrace" do
        lambda do
          @tweaker.tweak_backtrace(@error)
        end.should_not raise_error
      end

      it "gracefully handle backtraces with newlines" do
        @error.set_backtrace(["we like\nbin/spec:\nnewlines"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should include("we like\nnewlines")
      end

      it "cleans up double slashes" do
        @error.set_backtrace(["/a//b/c//d.rb"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should include("/a/b/c/d.rb")
      end

      it "preserves lines from textmate ruby bundle" do
        @error.set_backtrace(["/Applications/TextMate.app/Contents/SharedSupport/Bundles/Ruby.tmbundle/Support/tmruby.rb:147"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty
      end

      it "removes lines in lib/spec" do
        ["expectations", "mocks", "runner"].each do |child|
          element="/lib/spec/#{child}/anything.rb"
          @error.set_backtrace([element])
          @tweaker.tweak_backtrace(@error)
          @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
        end
      end

      it "removes lines in bin/spec" do
        @error.set_backtrace(["bin/spec:"])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty
      end

      it "removes lines in mock_frameworks/rspec" do
        element = "mock_frameworks/rspec"
        @error.set_backtrace([element])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
      end

      it "removes custom patterns" do
        element = "/vendor/lib/custom_pattern/"
        @tweaker.ignore_patterns /custom_pattern/
        @error.set_backtrace([element])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
      end

      it "removes custom patterns added as a string" do
        element = "/vendor/lib/custom_pattern/"
        @tweaker.ignore_patterns "custom_pattern"
        @error.set_backtrace([element])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
      end

      it "removes lines in mock_frameworks/rspec" do
        element = "mock_frameworks/rspec"
        @error.set_backtrace([element])
        @tweaker.tweak_backtrace(@error)
        @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
      end

      it "removes lines in rspec gem" do
        ["/rspec-1.2.3/lib/spec.rb","/rspec-1.2.3/lib/spec/anything.rb","bin/spec:123"].each do |element|
          @error.set_backtrace([element])
          @tweaker.tweak_backtrace(@error)
          @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
        end
      end

      it "removes lines in pre-release rspec gems" do
        ["/rspec-1.2.3.a1.gem/lib/spec.rb","/rspec-1.2.3.b1.gem/lib/spec.rb","/rspec-1.2.3.rc1.gem/lib/spec.rb"].each do |element|
          @error.set_backtrace([element])
          @tweaker.tweak_backtrace(@error)
          @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
        end
      end

      it "removes lines in spork gem" do
        ["/spork-1.2.3/lib/spec.rb","/spork-1.2.3/lib/spec/anything.rb","bin/spork:123"].each do |element|
          @error.set_backtrace([element])
          @tweaker.tweak_backtrace(@error)
          @error.backtrace.should be_empty, "Should have removed line with '#{element}'"
        end
      end
    end
  end
end
