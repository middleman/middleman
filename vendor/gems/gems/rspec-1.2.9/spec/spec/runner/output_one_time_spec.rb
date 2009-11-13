require 'spec_helper'
require 'ruby_forker'

module Spec
  module Runner
    describe CommandLine do
      include RubyForker
      it "should not output twice" do
        output = ruby "-Ilib bin/spec spec/spec/runner/output_one_time_fixture_runner.rb"
        output.should include("1 example, 0 failures")
        output.should_not include("0 examples, 0 failures")
      end
    end
  end
end