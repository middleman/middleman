require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    describe Console do
      include Console

      before(:each) do
        @io = mock('console output')
      end

      it "should not raise an error when there are no tags" do
        @tag_occurrences = nil

        lambda{print_tag_limit_warnings(:tag_names => {'@wip' => 2})}.should_not raise_error
      end
    end
  end
end
