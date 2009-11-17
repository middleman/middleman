require 'test_helper'

class Jeweler
  module Commands
    class TestBuildGem < Test::Unit::TestCase

      context "after running without a version" do
        setup do
          initialize_build_gem_environment
          @command.run
        end

        should "check if the gemspec helper has a version" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.has_version? }
        end

        should "update version of gemspec helper if the gemspec doesn't have a version" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.update_version(@version_helper)}
        end

        should "call gemspec helper's parse" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.parse }
        end

        should "build from parsed gemspec" do
          assert_received(Gem::Builder) {|builder_class| builder_class.new(@gemspec) }
          assert_received(@builder) {|builder| builder.build }
        end

        should 'make package directory' do
          assert_received(@file_utils) {|file_utils| file_utils.mkdir_p './pkg'}
        end

        should 'move built gem into package directory' do
          assert_received(@file_utils) {|file_utils| file_utils.mv './zomg-1.2.3.gem', './pkg'}
        end
      end
      
      context 'after running with a version' do
        setup do
          initialize_build_gem_environment true
          @command.run
        end
        
        should "check if the gemspec helper has a version" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.has_version? }
        end
        
        should "update version of gemspec helper if the gemspec doesn't have a version" do
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.update_version(@version_helper).never }
        end
        
      end

      build_command_context "build for jeweler" do
        setup do
          @command = Jeweler::Commands::BuildGem.build_for(@jeweler)
        end

        should "assign base_dir" do
          assert_same @base_dir, @jeweler.base_dir
        end

        should "assign gemspec_helper" do
          assert_same @gemspec_helper, @jeweler.gemspec_helper
        end

        should "return BuildGem" do
          assert_kind_of Jeweler::Commands::BuildGem, @command
        end
      end
      
      def initialize_build_gem_environment(has_version = false)
        @gemspec = Object.new
        stub(@gemspec).file_name { 'zomg-1.2.3.gem' }

        @gemspec_helper = Object.new
        stub(@gemspec_helper).parse { @gemspec }
        stub(@gemspec_helper).update_version
        stub(@gemspec_helper).has_version? { has_version }

        @version_helper = "Jeweler::VersionHelper"

        @builder = Object.new
        stub(Gem::Builder).new { @builder }
        stub(@builder).build { 'zomg-1.2.3.gem' }

        @file_utils = Object.new
        stub(@file_utils).mkdir_p './pkg'
        stub(@file_utils).mv './zomg-1.2.3.gem', './pkg'

        @base_dir = '.'

        @command = Jeweler::Commands::BuildGem.new
        @command.base_dir = @base_dir
        @command.file_utils = @file_utils
        @command.gemspec_helper = @gemspec_helper
        @command.version_helper = @version_helper
      end

    end
  end
end
