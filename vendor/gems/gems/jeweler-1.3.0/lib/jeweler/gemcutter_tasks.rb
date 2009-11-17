require 'rake'
require 'rake/tasklib'

class Jeweler
  # Rake tasks for putting a Jeweler gem on Gemcutter.
  #
  # Jeweler::Tasks.new needs to be used before this.
  #
  # Basic usage:
  #
  #     Jeweler::Gemcutter.new
  #
  # Easy enough, right?
  class GemcutterTasks < ::Rake::TaskLib
    attr_accessor :jeweler

    def initialize
      yield self if block_given?

      self.jeweler = Rake.application.jeweler

      define
    end

    def define
      namespace :gemcutter do
        desc "Release gem to Gemcutter"
        task :release => [:gemspec, :build] do
          jeweler.release_gem_to_gemcutter
        end
      end

      task :release => 'gemcutter:release'
    end
  end
end
