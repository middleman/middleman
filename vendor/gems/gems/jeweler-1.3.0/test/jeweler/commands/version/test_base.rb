require 'test_helper'

class Jeweler
  module Commands
    module Version
      class TestBase < Test::Unit::TestCase
        build_command_context "build for jeweler" do
          setup do
            @command = Jeweler::Commands::Version::Base.build_for(@jeweler)
          end

          should "assign repo" do
            assert_equal @repo, @command.repo
          end

          should "assign version_helper" do
            assert_equal @version_helper, @command.version_helper
          end

          should "assign gemspec" do
            assert_equal @gemspec, @command.gemspec
          end

          should"assign commit" do
            assert_equal @commit, @command.commit
          end
        end
      end
    end
  end
end

