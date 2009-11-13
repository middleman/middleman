require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Ast
    describe Background do

      before do
        extend(RbSupport::RbDsl)
        @step_mother = StepMother.new
        @step_mother.load_natural_language('en')
        @rb = @step_mother.load_programming_language('rb')

        $x = $y = nil
        Before do
          $x = 2
        end
        Given /y is (\d+)/ do |n|
          $y = $x * n.to_i
        end

        @visitor = TreeWalker.new(@step_mother)

        @feature = mock('feature', :visit? => true).as_null_object
      end

      it "should execute Before blocks before background steps" do
        background = Background.new(
          comment=Comment.new(''),
          line=2,
          keyword="", 
          name="",
          steps=[
            Step.new(7, "Given", "y is 5")
          ])

        scenario = Scenario.new(
          background,
          comment=Comment.new(""), 
          tags=Tags.new(98,[]),
          line=99,
          keyword="", 
          name="", 
          steps=[]
        )
        background.feature = @feature
        @visitor.visit_background(background)
        $x.should == 2
        $y.should == 10
      end
    end
  end
end
