require 'test_helper'

class Jeweler
  module Commands
    class TestReleaseToGemcutter < Test::Unit::TestCase
      def self.subject
        Jeweler::Commands::ReleaseToGemcutter.new
      end

      gemcutter_command_context "rubyforge_project is defined in gemspec and package exists on rubyforge" do
        setup do
          stub(@gemspec_helper).gem_path {'pkg/zomg-1.2.3.gem'}
          stub(@command).sh
          @command.run
        end

        should "push to gemcutter" do
          push_command = "gem push #{@gemspec_helper.gem_path}"
          assert_received(@command) { |command| command.sh(push_command) }
        end
      end

      build_command_context "build for jeweler" do
        setup do
          @command = Jeweler::Commands::ReleaseToGemcutter.build_for(@jeweler)
        end

        should "assign gemspec helper" do
          assert_equal @gemspec_helper, @command.gemspec_helper
        end

        should "assign output" do
          assert_equal @output, @command.output
        end
      end
      
    end
  end
end
