require 'rake'
require 'rake/tasklib'

class Rake::Application
  attr_accessor :jeweler_tasks

  # The jeweler instance that has be instantiated in the current Rakefile.
  #
  # This is usually useful if you want to get at info like version from other files.
  def jeweler
    jeweler_tasks.jeweler
  end
end

class Jeweler
  # Rake tasks for managing your gem.
  #
  # Here's a basic example of using it:
  #
  #   Jeweler::Tasks.new do |gem|
  #     gem.name = "jeweler"
  #     gem.summary = "Simple and opinionated helper for creating Rubygem projects on GitHub"
  #     gem.email = "josh@technicalpickles.com"
  #     gem.homepage = "http://github.com/technicalpickles/jeweler"
  #     gem.description = "Simple and opinionated helper for creating Rubygem projects on GitHub"
  #     gem.authors = ["Josh Nichols"]
  #   end
  #
  # The block variable gem is actually a Gem::Specification, so you can do anything you would normally do with a Gem::Specification. For more details, see the official gemspec reference: http://docs.rubygems.org/read/chapter/20 . In addition, it has a defaults set for you. See Jeweler::Specification for more details.
  class Tasks < ::Rake::TaskLib
    attr_accessor :gemspec, :jeweler, :gemspec_building_block

    def initialize(gemspec = nil, &gemspec_building_block)
      @gemspec = gemspec || Gem::Specification.new
      self.gemspec_building_block = gemspec_building_block

      Rake.application.jeweler_tasks = self
      define
    end

    def jeweler
      if @jeweler.nil?
        @jeweler = Jeweler.new(gemspec)
        gemspec_building_block.call gemspec if gemspec_building_block
      end
      @jeweler
    end

  private

    def yield_gemspec_set_version?
      yielded_gemspec = @gemspec.dup
      yielded_gemspec.extend(Jeweler::Specification)
      yielded_gemspec.files = FileList[]
      yielded_gemspec.test_files = FileList[]
      yielded_gemspec.extra_rdoc_files = FileList[]

      gemspec_building_block.call(yielded_gemspec) if gemspec_building_block

      ! yielded_gemspec.version.nil?
    end

    def define
      task :version_required do
        if jeweler.expects_version_file? && !jeweler.version_file_exists?
          abort "Expected VERSION or VERSION.yml to exist. See version:write to create an initial one."
        end
      end

      desc "Build gem"
      task :build do
        jeweler.build_gem
      end

      desc "Install gem using sudo"
      task :install => ['check_dependencies:runtime', :build] do
        jeweler.install_gem
      end

      desc "Generate and validates gemspec"
      task :gemspec => ['gemspec:generate', 'gemspec:validate']

      namespace :gemspec do
        desc "Validates the gemspec"
        task :validate => :version_required do
          jeweler.validate_gemspec
        end

        desc "Generates the gemspec, using version from VERSION"
        task :generate => :version_required do
          jeweler.write_gemspec
        end

        desc "Display the gemspec for debugging purposes"
        task :debug do
          puts jeweler.gemspec_helper.to_ruby
        end
      end

      desc "Displays the current version"
      task :version => :version_required do
        $stdout.puts "Current version: #{jeweler.version}"
      end

      unless yield_gemspec_set_version?
        namespace :version do
          desc "Writes out an explicit version. Respects the following environment variables, or defaults to 0: MAJOR, MINOR, PATCH. Also recognizes BUILD, which defaults to nil"
          task :write do
            major, minor, patch, build = ENV['MAJOR'].to_i, ENV['MINOR'].to_i, ENV['PATCH'].to_i, (ENV['BUILD'] || nil )
            jeweler.write_version(major, minor, patch, build, :announce => false, :commit => false)
            $stdout.puts "Updated version: #{jeweler.version}"
          end

          namespace :bump do
            desc "Bump the gemspec by a major version."
            task :major => [:version_required, :version] do
              jeweler.bump_major_version
              $stdout.puts "Updated version: #{jeweler.version}"
            end

            desc "Bump the gemspec by a minor version."
            task :minor => [:version_required, :version] do
              jeweler.bump_minor_version
              $stdout.puts "Updated version: #{jeweler.version}"
            end

            desc "Bump the gemspec by a patch version."
            task :patch => [:version_required, :version] do
              jeweler.bump_patch_version
              $stdout.puts "Updated version: #{jeweler.version}"
            end
          end
        end
      end

      namespace :github do
        task :release do
          jeweler.release_gem_to_github
        end
      end

      task :release => 'github:release'

      namespace :git do
        task :release do
          jeweler.release_to_git
        end
      end

      task :release => 'git:release'

      desc "Check that runtime and development dependencies are installed" 
      task :check_dependencies do
        jeweler.check_dependencies
      end

      namespace :check_dependencies do
        desc "Check that runtime dependencies are installed"
        task :runtime  do
          jeweler.check_dependencies(:runtime)
        end

        desc"Check that development dependencies are installed"
        task :development do
          jeweler.check_dependencies(:development)
        end

      end
      
    end
  end
end
