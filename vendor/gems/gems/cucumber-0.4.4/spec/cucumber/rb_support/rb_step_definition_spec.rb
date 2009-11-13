require File.dirname(__FILE__) + '/../../spec_helper'

require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      before do      
        @step_mother = StepMother.new
        @step_mother.load_natural_language('en')
        @rb = @step_mother.load_programming_language('rb')
        @dsl = Object.new 
        @dsl.extend RbSupport::RbDsl
        @step_mother.before(mock('scenario', :null_object => true))

        $inside = nil
      end
      
      it "should allow calling of other steps" do
        @dsl.Given /Outside/ do
          Given "Inside"
        end
        @dsl.Given /Inside/ do
          $inside = true
        end

        @step_mother.step_match("Outside").invoke(nil)
        $inside.should == true
      end

      it "should allow calling of other steps with inline arg" do
        @dsl.Given /Outside/ do
          Given "Inside", Ast::Table.new([['inside']])
        end
        @dsl.Given /Inside/ do |table|
          $inside = table.raw[0][0]
        end

        @step_mother.step_match("Outside").invoke(nil)
        $inside.should == 'inside'
      end

      it "should raise Undefined when inside step is not defined" do
        @dsl.Given /Outside/ do
          Given 'Inside'
        end

        lambda do
          @step_mother.step_match('Outside').invoke(nil)
        end.should raise_error(Undefined, 'Undefined step: "Inside"')
      end

      it "should allow forced pending" do
        @dsl.Given /Outside/ do
          pending("Do me!")
        end

        lambda do
          @step_mother.step_match("Outside").invoke(nil)
        end.should raise_error(Pending, "Do me!")
      end

      it "should raise ArityMismatchError when the number of capture groups differs from the number of step arguments" do
        @dsl.Given /No group: \w+/ do |arg|
        end

        lambda do
          @step_mother.step_match("No group: arg").invoke(nil)
        end.should raise_error(ArityMismatchError)
      end

      it "should allow announce" do
        v = mock('visitor')
        v.should_receive(:announce).with('wasup')
        @step_mother.visitor = v
        @dsl.Given /Loud/ do
          announce 'wasup'
        end
        
        @step_mother.step_match("Loud").invoke(nil)
      end
      
      it "should recognize $arg style captures" do
        @dsl.Given "capture this: $arg" do |arg|
          arg.should == 'this'
        end

       @step_mother.step_match('capture this: this').invoke(nil)
      end
      
    
      def unindented(s)
        s.split("\n")[1..-2].join("\n").indent(-10)
      end
    
      it "should recognise quotes in name and make according regexp" do
        @rb.snippet_text('Given', 'A "first" arg', nil).should == unindented(%{
          Given /^A "([^\\"]*)" arg$/ do |arg1|
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should recognise several quoted words in name and make according regexp and args" do
        @rb.snippet_text('Given', 'A "first" and "second" arg', nil).should == unindented(%{
          Given /^A "([^\\"]*)" and "([^\\"]*)" arg$/ do |arg1, arg2|
            pending # express the regexp above with the code you wish you had
          end
        })
      end
      
      it "should not use quote group when there are no quotes" do
        @rb.snippet_text('Given', 'A first arg', nil).should == unindented(%{
          Given /^A first arg$/ do
            pending # express the regexp above with the code you wish you had
          end
        })
      end

      it "should be helpful with tables" do
        @rb.snippet_text('Given', 'A "first" arg', Cucumber::Ast::Table).should == unindented(%{
          Given /^A "([^\\"]*)" arg$/ do |arg1, table|
            # table is a Cucumber::Ast::Table
            pending # express the regexp above with the code you wish you had
          end
        })
      end
    end
  end
end
