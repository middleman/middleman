# Our custom logger
require "middleman-core/logger"

# For instrumenting
require "active_support/notifications"

# Using Thor's indifferent hash access
require "thor"

# Core Pathname library used for traversal
require "pathname"

require "tilt"
require "rack/mime"

module Middleman

  module Util

    # Whether the source file is binary.
    #
    # @param [String] filename The file to check.
    # @return [Boolean]
    def self.binary?(filename)
      ext = File.extname(filename)
      return true if ext == '.svgz'
      return false if Tilt.registered?(ext.sub('.',''))

      ext = ".#{ext}" unless ext.to_s[0] == ?.
      mime = ::Rack::Mime.mime_type(ext, nil) 
      unless mime
        binary_bytes = [0, 1, 2, 3, 4, 5, 6, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31]
        s = File.read(filename, 4096) || ''        
        s.each_byte do |c|
          return true if binary_bytes.include?(c)          
        end
        return false
      end
      return false if mime.start_with?('text/')
      return false if mime.include?('xml')
      return false if mime.include?('json')
      return false if mime.include?('javascript')
      true
    end

    # The logger
    #
    # @return [Middleman::Logger] The logger
    def self.logger(*args)
      if !@_logger || args.length > 0
        @_logger = ::Middleman::Logger.new(*args)
      end

      @_logger
    end

    # Facade for ActiveSupport/Notification
    def self.instrument(name, payload={}, &block)
      name << ".middleman" unless name =~ /\.middleman$/
      ::ActiveSupport::Notifications.instrument(name, payload, &block)
    end

    # Recursively convert a normal Hash into a HashWithIndifferentAccess
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Thor::CoreExt::HashWithIndifferentAccess]
    def self.recursively_enhance(data)
      if data.is_a? Hash
        data = ::Thor::CoreExt::HashWithIndifferentAccess.new(data)
        data.each do |key, val|
          data[key] = recursively_enhance(val)
        end
        data
      elsif data.is_a? Array
        data.each_with_index do |val, i|
          data[i] = recursively_enhance(val)
        end
        data
      else
        data
      end
    end

    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    def self.normalize_path(path)
      # The tr call works around a bug in Ruby's Unicode handling
      path.sub(%r{^/}, "").tr('','')
    end

    # This is a separate method from normalize_path in case we
    # change how we normalize paths
    def self.strip_leading_slash(path)
      path.sub(%r{^/}, "")
    end

    # Extract the text of a Rack response as a string.
    # Useful for extensions implemented as Rack middleware.
    # @param response The response from #call
    # @return [String] The whole response as a string.
    def self.extract_response_text(response)
      # The rack spec states all response bodies must respond to each
      result = ''
      response.each do |part, s|
        result << part
      end
      result
    end

    # Takes a matcher, which can be a literal string
    # or a string containing glob expressions, or a
    # regexp, or a proc, or anything else that responds
    # to #match or #call, and returns whether or not the
    # given path matches that matcher.
    #
    # @param matcher A matcher string/regexp/proc/etc
    # @param path A path as a string
    # @return [Boolean] Whether the path matches the matcher
    def self.path_match(matcher, path)
      if matcher.respond_to? :match
        matcher.match path
      elsif matcher.respond_to? :call
        matcher.call path
      else
        File.fnmatch(matcher.to_s, path)
      end
    end

    # Get a recusive list of files inside a set of paths.
    # Works with symlinks.
    #
    # @param path A path string or Pathname
    # @return [Array] An array of filenames
    def self.all_files_under(*paths)
      paths.flatten!
      paths.map! { |p| Pathname(p) }
      files = paths.select { |p| p.file? }
      paths.select {|p| p.directory? }.each do |dir|
        files << all_files_under(dir.children)
      end
      files.flatten
    end

    # Simple shared cache implementation
    class Cache
      # Initialize
      def initialize
        self.clear
      end

      # Either get the cached key or save the contents of the block
      #
      # @param key Anything Hash can use as a key
      def fetch(*key)
        @cache[key] ||= yield
      end

      # Whether the key is in the cache
      #
      # @param key Anything Hash can use as a key
      # @return [Boolean]
      def has_key?(key)
        @cache.has_key?(key)
      end

      # Get a specific key
      #
      # @param key Anything Hash can use as a key
      def get(key)
        @cache[key]
      end

      # Array of keys
      # @return [Array]
      def keys
        @cache.keys
      end

      # Clear the entire cache
      # @return [void]
      def clear
        @cache = {}
      end

      # Set a specific key
      #
      # @param key Anything Hash can use as a key
      # @param value Cached value
      # @return [void]
      def set(key, value)
        @cache[key] = value
      end

      # Remove a specific key
      # @param key Anything Hash can use as a key
      def remove(*key)
        @cache.delete(key)
      end
    end
  end
end
