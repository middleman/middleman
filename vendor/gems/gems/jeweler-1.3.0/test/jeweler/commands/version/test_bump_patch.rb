require 'test_helper'

class Jeweler
  module Commands
    module Version
      class TestBumpPatch < Test::Unit::TestCase

        should "call bump_patch on version_helper in update_version" do
          mock(version_helper = Object.new).bump_patch

          command = Jeweler::Commands::Version::BumpPatch.new
          command.version_helper = version_helper

          command.update_version
        end
      end
    end
  end
end

