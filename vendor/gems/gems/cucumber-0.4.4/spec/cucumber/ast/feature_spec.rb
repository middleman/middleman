require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/feature_factory'

module Cucumber
  module Ast
    describe Feature do
      include FeatureFactory

      it "should convert to sexp" do
        step_mother = StepMother.new
        step_mother.load_natural_language('en')
        step_mother.load_programming_language('rb')
        dsl = Object.new 
        dsl.extend RbSupport::RbDsl

        feature = create_feature(dsl)
        feature.to_sexp.should == 
        [:feature,
          "features/pretty_printing.feature",
          "Pretty printing", 
          [:comment, "# My feature comment\n"], 
          [:tag, "one"], 
          [:tag, "two"], 
          [:background, 2, 'Background:',
            [:step, 3, "Given", "a passing step"]],
          [:scenario, 9, "Scenario:", 
            "A Scenario", 
            [:comment, "    # My scenario comment  \n# On two lines \n"], 
            [:tag, "three"], 
            [:tag, "four"],
            [:step_invocation, 3, "Given", "a passing step"], # From the background
            [:step_invocation, 10, "Given", "a passing step with an inline arg:",
              [:table, 
                [:row, -1,
                  [:cell, "1"], [:cell, "22"], [:cell, "333"]], 
                [:row, -1,
                  [:cell, "4444"], [:cell, "55555"], [:cell, "666666"]]]], 
            [:step_invocation, 11, "Given", "a happy step with an inline arg:", 
              [:py_string, "\n I like\nCucumber sandwich\n"]], 
            [:step_invocation, 12, "Given", "a failing step"]]]
      end
    end
  end
end
