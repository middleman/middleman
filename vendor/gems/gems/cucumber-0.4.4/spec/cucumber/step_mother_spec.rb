require File.dirname(__FILE__) + '/../spec_helper'

require 'cucumber'
require 'cucumber/rb_support/rb_language'

module Cucumber
  describe StepMother do
    before do
      @dsl = Object.new
      @dsl.extend(RbSupport::RbDsl)

      @step_mother = StepMother.new
      @step_mother.load_natural_language('en')
      @rb = @step_mother.load_programming_language('rb')

      @visitor = mock('Visitor')
    end

    it "should format step names" do
      @dsl.Given(/it (.*) in (.*)/) do |what, month|
      end
      @dsl.Given(/nope something else/) do |what, month|
      end
      
      format = @step_mother.step_match("it snows in april").format_args("[%s]")
      format.should == "it [snows] in [april]"
    end

    it "should raise Ambiguous error with guess hint when multiple step definitions match" do
      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three blind (.*)/) {|animal|}

      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three blind mice":

spec/cucumber/step_mother_spec.rb:30:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:31:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
})
    end

    it "should not show --guess hint when --guess is used" do
      @step_mother.options = {:guess => true}

      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three cute (.*)/) {|animal|}
      
      lambda do
        @step_mother.step_match("Three cute mice")
      end.should raise_error(Ambiguous, %{Ambiguous match of "Three cute mice":

spec/cucumber/step_mother_spec.rb:47:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:48:in `/Three cute (.*)/'

})
    end

    it "should not raise Ambiguous error when multiple step definitions match, but --guess is enabled" do
      @step_mother.options = {:guess => true}
      @dsl.Given(/Three (.*) mice/) {|disability|}
      @dsl.Given(/Three (.*)/) {|animal|}
      
      lambda do
        @step_mother.step_match("Three blind mice")
      end.should_not raise_error
    end
    
    it "should pick right step definition when --guess is enabled and equal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @dsl.Given(/Three (.*) mice/) {|disability|}
      wrong = @dsl.Given(/Three (.*)/) {|animal|}
      
      @step_mother.step_match("Three blind mice").step_definition.should == right
    end
    
    it "should pick right step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      right = @dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
      wrong = @dsl.Given(/Three (.*)/) {|animal|}
      
      @step_mother.step_match("Three blind mice ran far").step_definition.should == right
    end

    it "should pick most specific step definition when --guess is enabled and unequal number of capture groups" do
      @step_mother.options = {:guess => true}
      general       = @dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
      specific      = @dsl.Given(/Three blind mice ran far/) {}
      more_specific = @dsl.Given(/^Three blind mice ran far$/) {}
      
      @step_mother.step_match("Three blind mice ran far").step_definition.should == more_specific
    end
    
    it "should raise Undefined error when no step definitions match" do
      lambda do
        @step_mother.step_match("Three blind mice")
      end.should raise_error(Undefined)
    end

    # http://railsforum.com/viewtopic.php?pid=93881
    it "should not raise Redundant unless it's really redundant" do
      @dsl.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
      @dsl.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
    end

    it "should raise an error if the world is nil" do
      @dsl.World do
      end

      begin
        @step_mother.before_and_after(nil) {}
        raise "Should fail"
      rescue RbSupport::NilWorld => e
        e.message.should == "World procs should never return nil"
        e.backtrace.should == ["spec/cucumber/step_mother_spec.rb:108:in `World'"]
      end
    end

    module ModuleOne
    end

    module ModuleTwo
    end

    class ClassOne
    end

    it "should implicitly extend world with modules" do
      @dsl.World(ModuleOne, ModuleTwo)
      @step_mother.before(mock('scenario', :null_object => true))
      class << @rb.current_world
        included_modules.index(ModuleOne).should_not == nil
        included_modules.index(ModuleTwo).should_not == nil
      end
      @rb.current_world.class.should == Object
    end

    it "should raise error when we try to register more than one World proc" do
      @dsl.World { Hash.new }
      lambda do
        @dsl.World { Array.new }
      end.should raise_error(RbSupport::MultipleWorld, %{You can only pass a proc to #World once, but it's happening
in 2 places:

spec/cucumber/step_mother_spec.rb:140:in `World'
spec/cucumber/step_mother_spec.rb:142:in `World'

Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc
or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.

})
    end

    it "should find before hooks" do
      fish = @dsl.Before('@fish'){}
      meat = @dsl.Before('@meat'){}
            
      scenario = mock('Scenario')
      scenario.should_receive(:accept_hook?).with(fish).and_return(true)
      scenario.should_receive(:accept_hook?).with(meat).and_return(false)
      
      @rb.hooks_for(:before, scenario).should == [fish]
    end
  end

  describe StepMother, "step argument transformations" do
    before do
      @dsl = Object.new
      @dsl.extend(RbSupport::RbDsl)

      @step_mother = StepMother.new
      @step_mother.load_natural_language('en')
      @rb = @step_mother.load_programming_language('rb')
    end

    describe "without capture groups" do
      it "complains when registering with a with no transform block" do
        lambda do
          @dsl.Transform('^abc$')
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end
      
      it "complains when registering with a zero-arg transform block" do
        lambda do
          @dsl.Transform('^abc$') {42}
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a splat-arg transform block" do
        lambda do
          @dsl.Transform('^abc$') {|*splat| 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when transforming with an arity mismatch" do
        lambda do
          @dsl.Transform('^abc$') {|one, two| 42 }
          @rb.execute_transforms(['abc'])
        end.should raise_error(Cucumber::ArityMismatchError)
      end

      it "allows registering a regexp pattern that yields the step_arg matched" do
        @dsl.Transform(/^ab*c$/) {|arg| 42}
        @rb.execute_transforms(['ab']).should == ['ab']
        @rb.execute_transforms(['ac']).should == [42]
        @rb.execute_transforms(['abc']).should == [42]
        @rb.execute_transforms(['abbc']).should == [42]
      end
    end

    describe "with capture groups" do
      it "complains when registering with a with no transform block" do
        lambda do
          @dsl.Transform('^a(.)c$')
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end
      
      it "complains when registering with a zero-arg transform block" do
        lambda do
          @dsl.Transform('^a(.)c$') { 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when registering with a splat-arg transform block" do
        lambda do
          @dsl.Transform('^a(.)c$') {|*splat| 42 }
        end.should raise_error(Cucumber::RbSupport::RbTransform::MissingProc)
      end

      it "complains when transforming with an arity mismatch" do
        lambda do
          @dsl.Transform('^a(.)c$') {|one, two| 42 }
          @rb.execute_transforms(['abc'])
        end.should raise_error(Cucumber::ArityMismatchError)
      end
      
      it "allows registering a regexp pattern that yields capture groups" do
        @dsl.Transform(/^shape: (.+), color: (.+)$/) do |shape, color|
          {shape.to_sym => color.to_sym}
        end
        @rb.execute_transforms(['shape: circle, color: blue']).should == [{:circle => :blue}]
        @rb.execute_transforms(['shape: square, color: red']).should == [{:square => :red}]
        @rb.execute_transforms(['not shape: square, not color: red']).should == ['not shape: square, not color: red']
      end
    end
    
    it "allows registering a string pattern" do
      @dsl.Transform('^ab*c$') {|arg| 42}
      @rb.execute_transforms(['ab']).should == ['ab']
      @rb.execute_transforms(['ac']).should == [42]
      @rb.execute_transforms(['abc']).should == [42]
      @rb.execute_transforms(['abbc']).should == [42]
    end

    it "gives match priority to transforms defined last" do
      @dsl.Transform(/^transform_me$/) {|arg| :foo }
      @dsl.Transform(/^transform_me$/) {|arg| :bar }
      @dsl.Transform(/^transform_me$/) {|arg| :baz }
      @rb.execute_transforms(['transform_me']).should == [:baz]
    end
    
    it "allows registering a transform which returns nil" do
      @dsl.Transform('^ac$') {|arg| nil}
      @rb.execute_transforms(['ab']).should == ['ab']
      @rb.execute_transforms(['ac']).should == [nil]
    end
  end

end
