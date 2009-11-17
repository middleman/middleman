require 'test_helper'

class Jeweler
  module Commands
    class TestValidateGemspec < Test::Unit::TestCase

      build_command_context "build context" do
        setup do
          @command = Jeweler::Commands::ValidateGemspec.build_for(@jeweler)
        end

        should "assign gemspec_helper" do
          assert_same @gemspec_helper, @command.gemspec_helper
        end

        should "assign output" do
          assert_same @output, @command.output
        end

        should "return Jeweler::Commands::ValidateGemspec" do
          assert_kind_of Jeweler::Commands::ValidateGemspec, @command
        end

      end
    end
  end
end
