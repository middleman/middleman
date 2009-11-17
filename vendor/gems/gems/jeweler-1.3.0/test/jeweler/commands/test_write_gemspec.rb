require 'test_helper'

class Jeweler
  module Commands
    class TestWriteGemspec < Test::Unit::TestCase

      context "after run" do
        setup do
          @gemspec = Gem::Specification.new {|s| s.name = 'zomg' }
          @gemspec_helper = Object.new
          stub(@gemspec_helper).spec { @gemspec }
          stub(@gemspec_helper).path { 'zomg.gemspec' }
          stub(@gemspec_helper).write

          @output = StringIO.new

          @version_helper = Object.new
          stub(@version_helper).to_s  { '1.2.3' }
          stub(@version_helper).refresh

          @command = Jeweler::Commands::WriteGemspec.new
          @command.base_dir = 'tmp'
          @command.version_helper = @version_helper
          @command.gemspec = @gemspec
          @command.output = @output
          @command.gemspec_helper = @gemspec_helper

          @now = Time.now
          stub(Time.now).now { @now }
        end

        should "refresh version" do
          @command.run
          assert_received(@version_helper) {|version_helper| version_helper.refresh }
        end

        should "update gemspec version" do
          @command.run
          assert_equal '1.2.3', @gemspec.version.to_s
        end

        should "not refresh version neither update version if it's set on the gemspec" do
          @gemspec.version = '2.3.4'
          @command.run
          assert_equal '2.3.4', @gemspec.version.to_s
        end

        should "update gemspec date to the beginning of today" do
          @command.run
          assert_equal Time.mktime(@now.year, @now.month, @now.day, 0, 0), @gemspec.date
        end

        should "write gemspec" do
          @command.run
          assert_received(@gemspec_helper) {|gemspec_helper| gemspec_helper.write }
        end

        should_eventually "output that the gemspec was written" do
          @command.run
          assert_equal @output.string, "Generated: tmp/zomg.gemspec"
        end

      end

      build_command_context "building for jeweler" do
        setup do
          @command = Jeweler::Commands::WriteGemspec.build_for(@jeweler)
        end

        should "assign base_dir" do
          assert_same @base_dir, @command.base_dir
        end

        should "assign gemspec" do
          assert_same @gemspec, @command.gemspec
        end

        should "assign version" do
          assert_same @version, @command.version
        end

        should "assign output" do
          assert_same @output, @command.output
        end

        should "assign gemspec_helper" do
          assert_same @gemspec_helper, @command.gemspec_helper
        end

        should "assign version_helper" do
          assert_same @version_helper, @command.version_helper
        end

        should "return WriteGemspec" do
          assert_kind_of Jeweler::Commands::WriteGemspec, @command
        end
      end

    end
  end
end
