class Jeweler
  module Commands
    module Version
      class Write < Base
        attr_accessor :major, :minor, :patch, :build
        def update_version
          version_helper.update_to major, minor, patch, build
        end
      end
    end
  end
end
