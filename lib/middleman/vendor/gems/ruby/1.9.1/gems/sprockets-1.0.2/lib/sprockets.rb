$:.unshift File.dirname(__FILE__)

require "yaml"
require "fileutils"

module Sprockets
  class << self
    def running_on_windows?
      RUBY_PLATFORM =~ /(win|w)32$/
    end
  
    def absolute?(location)
      same_when_expanded?(location) || platform_absolute_path?(location)
    end

    protected
      def same_when_expanded?(location)
        location[0, 1] == File.expand_path(location)[0, 1]
      end

      def platform_absolute_path?(location)
        false
      end

      if Sprockets.running_on_windows?
        def platform_absolute_path?(location)
          location[0, 1] == File::SEPARATOR && File.expand_path(location) =~ /[A-Za-z]:[\/\\]/
        end
      end
  end
end

require "sprockets/version"
require "sprockets/error"
require "sprockets/environment"
require "sprockets/pathname"
require "sprockets/source_line"
require "sprockets/source_file"
require "sprockets/concatenation"
require "sprockets/preprocessor"
require "sprockets/secretary"

