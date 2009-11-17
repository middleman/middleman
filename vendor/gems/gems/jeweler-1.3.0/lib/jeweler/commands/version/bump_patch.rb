class Jeweler
  module Commands
    module Version
      class BumpPatch < Base

        def update_version
          self.version_helper.bump_patch
        end

      end
    end
  end
end

