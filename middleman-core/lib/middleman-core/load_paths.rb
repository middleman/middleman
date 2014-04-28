# Core Pathname library used for traversal
require 'pathname'

module Middleman
  class << self
    def setup_load_paths
      @_is_setup ||= begin

        # Only look for config.rb if MM_ROOT isn't set
        if !ENV['MM_ROOT'] && found_path = locate_root
          ENV['MM_ROOT'] = found_path
        end

        is_bundler_setup = false

        # If we've found the root, try to setup Bundler
        if ENV['MM_ROOT']

          root_gemfile = File.expand_path('Gemfile', ENV['MM_ROOT'])
          ENV['BUNDLE_GEMFILE'] ||= root_gemfile

          unless File.exist?(ENV['BUNDLE_GEMFILE'])
            git_gemfile = Pathname.new(__FILE__).expand_path.parent.parent.parent + 'Gemfile'
            ENV['BUNDLE_GEMFILE'] = git_gemfile.to_s
          end

          if File.exist?(ENV['BUNDLE_GEMFILE'])
            is_bundler_setup = true
            require 'bundler/setup'
          end
        end

        # Automatically discover extensions in RubyGems
        require 'middleman-core/extensions'

        if is_bundler_setup
          Bundler.require
        else
          ::Middleman.load_extensions_in_path
        end

        true
      end
    end

    # Recursive method to find config.rb
    def locate_root(cwd=Pathname.new(Dir.pwd))
      return cwd.to_s if (cwd + 'config.rb').exist?
      return false if cwd.root?
      locate_root(cwd.parent)
    end
  end
end
