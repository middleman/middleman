class Jeweler
  module Commands
    module Version
      class BumpMinor < Base
        
        def update_version
          self.version_helper.bump_minor
        end
      end
    end
  end
end
