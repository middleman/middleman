require 'rbconfig'

module FSSM::Support
  class << self
    def backend
      @@backend ||= case
        when mac? && !jruby? && carbon_core?
          'FSEvents'
        when linux? && rb_inotify?
          'Inotify'
        else
          'Polling'
      end
    end

    def jruby?
      defined?(JRUBY_VERSION)
    end

    def mac?
      Config::CONFIG['target_os'] =~ /darwin/i
    end

    def linux?
      Config::CONFIG['target_os'] =~ /linux/i
    end

    def carbon_core?
      begin
        require 'osx/foundation'
        OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
        true
      rescue LoadError
        STDERR.puts("Warning: Unable to load CarbonCore. FSEvents will be unavailable.")
        false
      end
    end

    def rb_inotify?
      begin
        require 'rubygems'
        gem 'rb-inotify', '>= 0.3.0'
        require 'rb-inotify'
        true
      rescue LoadError, Gem::LoadError
        STDERR.puts("Warning: Unable to load rb-inotify >= 0.3.0. Inotify will be unavailable.")
        false
      end
    end

  end
end
