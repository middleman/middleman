require 'test_helper'

class Jeweler
  module Commands
    module Version
      class TestWrite < Test::Unit::TestCase

        should "call write_version on version_helper in update_version" do
          mock(version_helper = Object.new).update_to 1, 2, 3, nil

          command = Jeweler::Commands::Version::Write.new
          command.version_helper = version_helper
          command.major = 1
          command.minor = 2
          command.patch = 3
          command.update_version
        end
      end
    end
  end
end

