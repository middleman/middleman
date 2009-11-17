require 'rake'
require 'rake/tasklib'

class Jeweler
  # Rake tasks for putting a Jeweler gem on Rubyforge.
  #
  # Jeweler::Tasks.new needs to be used before this.
  #
  # Basic usage:
  #
  #     Jeweler::RubyforgeTasks.new
  #
  # Easy enough, right?
  # 
  # There are a few options you can tweak:
  #
  #  * project: the rubyforge project to operate on. This defaults to whatever you specified in your gemspec. Defaults to your gem name.
  #  * remote_doc_path: the place to upload docs to on Rubyforge under /var/www/gforge-projects/#{project}/
  #
  # See also http://wiki.github.com/technicalpickles/jeweler/rubyforge
  class RubyforgeTasks < ::Rake::TaskLib
    # The RubyForge project to interact with. Defaults to whatever is in your jeweler gemspec.
    attr_accessor :project
    # The path to upload docs to. It is relative to /var/www/gforge-projects/#{project}/, and defaults to your gemspec's name
    attr_accessor :remote_doc_path
    # Task to be used for generating documentation, before they are uploaded. Defaults to rdoc.
    attr_accessor :doc_task

    attr_accessor :jeweler

    def initialize
      yield self if block_given?

      self.doc_task = :rdoc if self.doc_task == nil # be sure to allow it to be set to false, to allow disabling

      define
    end

    def jeweler
      @jeweler ||= Rake.application.jeweler
    end

    def remote_doc_path
      @remote_doc_path ||= jeweler.gemspec.name
    end

    def project
      @project ||= jeweler.gemspec.rubyforge_project
    end

    def define
      namespace :rubyforge do

        namespace :release do
          desc "Release the current gem version to RubyForge."
          task :gem => [:gemspec, :build] do
            begin
              jeweler.release_gem_to_rubyforge
            rescue NoRubyForgeProjectInGemspecError => e
              abort "Setting up RubyForge requires that you specify a 'rubyforge_project' in your Jeweler::Tasks declaration"
            rescue MissingRubyForgePackageError => e
              abort "Rubyforge reported that the #{e.message} package isn't setup. Run rake rubyforge:setup to do so."
            rescue RubyForgeProjectNotConfiguredError => e
              abort "RubyForge reported that #{e.message} wasn't configured. This means you need to run 'rubyforge setup', 'rubyforge login', and 'rubyforge configure', or maybe the project doesn't exist on RubyForge"
            end
          end

          if publish_documentation?
            desc "Publish docs to RubyForge."
            task :docs => doc_task do
              config = YAML.load(
                File.read(File.expand_path('~/.rubyforge/user-config.yml'))
              )

              host = "#{config['username']}@rubyforge.org"
              remote_dir = "/var/www/gforge-projects/#{project}/#{remote_doc_path}"

              local_dir = case self.doc_task.to_sym
                          when :rdoc then 'rdoc'
                          when :yardoc then 'doc'
                          else
                            raise "Unsure what to run to generate documentation. Please set doc_task and re-run."
                          end

              sh %{rsync --archive --verbose --delete #{local_dir}/ #{host}:#{remote_dir}}
            end
          end
        end


        desc "Release gem and RDoc documentation to RubyForge"
        task :release => "rubyforge:release:gem"
        task :release => "rubyforge:release:docs" if publish_documentation?
          

        desc "Setup a rubyforge project for this gem"
        task :setup do
          begin 
            jeweler.setup_rubyforge
          rescue NoRubyForgeProjectInGemspecError => e
            abort "Setting up RubyForge requires that you specify a 'rubyforge_project' in your Jeweler::Tasks declaration"
          rescue RubyForgeProjectNotConfiguredError => e
            abort "The RubyForge reported that #{e.message} wasn't configured. This means you need to run 'rubyforge setup', 'rubyforge login', and 'rubyforge configure', or maybe the project doesn't exist on RubyForge"
          end
        end

      end

      task :release => 'rubyforge:release'
    end

    def publish_documentation?
      ! (doc_task == false || doc_task == :none)
    end
  end
end
