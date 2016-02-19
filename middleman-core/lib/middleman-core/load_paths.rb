# Core Pathname library used for traversal
require 'pathname'

module Middleman
  class << self
    def setup_load_paths
      @_is_setup ||= begin

        # Only look for config.rb if MM_ROOT isn't set
        if !ENV['MM_ROOT'] && (found_path = findup('config.rb'))
          ENV['MM_ROOT'] = found_path
        end

        # If we've found the root, try to setup Bundler
        setup_bundler if ENV['MM_ROOT']

        true
      end
    end

    private

    # Set BUNDLE_GEMFILE and run Bundler setup. Raises an exception if there is no Gemfile
    def setup_bundler
      if found_gemfile_root = findup('Gemfile', ENV['MM_ROOT'])
        ENV['BUNDLE_GEMFILE'] ||= File.join(found_gemfile_root, 'Gemfile')
      end

      unless File.exist?(ENV['BUNDLE_GEMFILE'])
        ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../../Gemfile', __FILE__)
      end

      if File.exist?(ENV['BUNDLE_GEMFILE'])
        require 'bundler/setup'
        Bundler.require
      else
        raise "Couldn't find your Gemfile. Middleman projects require a Gemfile for specifying dependencies."
      end
    end

    # Recursive method to find a file in parent directories
    def findup(filename, cwd=Dir.pwd)
      cwd = Pathname(cwd)
      return cwd.to_s if (cwd + filename).exist?
      return false if cwd.root?
      findup(filename, cwd.parent)
    end
  end
end
