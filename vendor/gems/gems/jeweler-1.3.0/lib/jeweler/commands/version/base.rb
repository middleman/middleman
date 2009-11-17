class Jeweler
  module Commands
    module Version
      class Base

        attr_accessor :repo, :version_helper, :gemspec, :commit

        def run
          update_version

          self.version_helper.write
          self.gemspec.version = self.version_helper.to_s

          commit_version if self.repo && self.commit
        end

        def update_version
          raise "Subclasses should implement this"
        end

        def commit_version
          if self.repo
            self.repo.add(version_helper.path)
            self.repo.commit("Version bump to #{self.version_helper.to_s}")
          end
        end


        def self.build_for(jeweler)
          command = new
          command.repo = jeweler.repo
          command.version_helper = jeweler.version_helper
          command.gemspec = jeweler.gemspec
          command.commit = jeweler.commit

          command
        end
      end
    end
  end
end
