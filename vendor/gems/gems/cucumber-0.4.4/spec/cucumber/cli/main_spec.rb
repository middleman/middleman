require File.dirname(__FILE__) + '/../../spec_helper'
require 'yaml'
begin
  require 'spec/runner/differs/default' # RSpec >=1.2.4
rescue ::LoadError
  require 'spec/expectations/differs/default' # RSpec <=1.2.3
end

module Cucumber
  module Cli
    describe Main do
      before(:each) do
        @out = StringIO.new
        @err = StringIO.new
        Kernel.stub!(:exit).and_return(nil)
        File.stub!(:exist?).and_return(false) # When Configuration checks for cucumber.yml
        Dir.stub!(:[]).and_return([]) # to prevent cucumber's features dir to being laoded
      end

      describe "verbose mode" do

        before(:each) do
          @empty_feature = Ast::Feature.new(nil, Ast::Comment.new(''), Ast::Tags.new(2, []), "Feature", [])
        end

        it "should show feature files parsed" do
          @cli = Main.new(%w{--verbose example.feature}, @out)
          @cli.stub!(:require)

          FeatureFile.stub!(:new).and_return(mock("feature file", :parse => @empty_feature))

          @cli.execute!(StepMother.new)

          @out.string.should include('example.feature')
        end

      end

      describe "diffing" do

        before :each do
          @configuration = mock('Configuration', :null_object => true, :drb? => false)
          Configuration.should_receive(:new).and_return(@configuration)

          @step_mother = mock('StepMother', :null_object => true)

          @cli = Main.new(nil, @out)
        end

        it "uses Spec Differ::Default when diff is enabled" do
          @configuration.should_receive(:diff_enabled?).and_return(true)

          ::Spec::Expectations::Differs::Default.should_receive(:new)

          @cli.execute!(@step_mother)
        end

        it "does not use Spec Differ::Default when diff is disabled" do
          @configuration.should_receive(:diff_enabled?).and_return(false)

          ::Spec::Expectations::Differs::Default.should_not_receive(:new)

          @cli.execute!(@step_mother)
        end

      end

      describe "--format with class" do

       describe "in module" do

          it "should resolve each module until it gets Formatter class" do
            cli = Main.new(%w{--format ZooModule::MonkeyFormatterClass}, nil)
            mock_module = mock('module')
            Object.stub!(:const_defined?).and_return(true)
            mock_module.stub!(:const_defined?).and_return(true)

            f = stub('formatter', :null_object => true)

            Object.should_receive(:const_get).with('ZooModule').and_return(mock_module)
            mock_module.should_receive(:const_get).with('MonkeyFormatterClass').and_return(mock('formatter class', :new => f))

            cli.execute!(StepMother.new)
          end

        end
      end

      describe "setup step sequence" do
        
        it "should load files and execute hooks in order" do
          Configuration.stub!(:new).and_return(configuration = mock('configuration', :null_object => true))
          step_mother = mock('step mother', :null_object => true)
          configuration.stub!(:drb?).and_return false
          cli = Main.new(%w{--verbose example.feature}, @out)
          cli.stub!(:require)
          
          configuration.stub!(:support_to_load).and_return(['support'])
          configuration.stub!(:step_defs_to_load).and_return(['step defs'])
          
          # Support must be loaded first to ensure post configuration hook can
          # run before anything else.
          step_mother.should_receive(:load_code_files).with(['support']).ordered
          # The post configuration hook/s (if any) need to be run next to enable
          # extensions to do their thing before features are loaded
          step_mother.should_receive(:after_configuration).with(configuration).ordered
          # Feature files must be loaded before step definitions are required.
          # This is because i18n step methods are only aliased when
          # features are loaded. If we swap the order, the requires
          # will fail.
          step_mother.should_receive(:load_plain_text_features).ordered
          step_mother.should_receive(:load_code_files).with(['step defs']).ordered

          cli.execute!(step_mother)
        end
        
      end
      
    [ProfilesNotDefinedError, YmlLoadError, ProfileNotFound].each do |exception_klass|

      it "rescues #{exception_klass}, prints the message to the error stream and returns true" do
        Configuration.stub!(:new).and_return(configuration = mock('configuration'))
        configuration.stub!(:parse!).and_raise(exception_klass.new("error message"))

        main = Main.new('', out = StringIO.new, error = StringIO.new)
        main.execute!(StepMother.new).should be_true
        error.string.should == "error message\n"
      end
    end


      context "--drb" do
        before(:each) do
          @configuration = mock('Configuration', :drb? => true, :null_object => true)
          Configuration.stub!(:new).and_return(@configuration)

          @args = ['features']

          @cli = Main.new(@args, @out, @err)
          @step_mother = mock('StepMother', :null_object => true)
        end

        it "delegates the execution to the DRB client passing the args and streams" do
          @configuration.stub :drb_port => 1450
          DRbClient.should_receive(:run).with(@args, @err, @out, 1450).and_return(true)
          @cli.execute!(@step_mother)
        end

        it "returns the result from the DRbClient" do
          DRbClient.stub!(:run).and_return('foo')
          @cli.execute!(@step_mother).should == 'foo'
        end

        it "ceases execution if the DrbClient is able to perform the execution" do
          DRbClient.stub!(:run).and_return(true)
          @configuration.should_not_receive(:build_formatter_broadcaster)
          @cli.execute!(@step_mother)
        end

        context "when the DrbClient is unable to perfrom the execution" do
          before { DRbClient.stub!(:run).and_raise(DRbClientError.new('error message.')) }

          it "alerts the user that execution will be performed locally" do
            @cli.execute!(@step_mother)
            @err.string.should include("WARNING: error message. Running features locally:")
          end

        end
      end
    end
  end
end
