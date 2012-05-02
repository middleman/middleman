# Using Thor's indifferent hash access
require "thor"

module Middleman
  module Util
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
      path.sub(/^\//, "").tr('','') 
    end

    # Extract the text of a Rack response as a string.
    # Useful for extensions implemented as Rack middleware.
    # @param response The response from #call
    # @return [String] The whole response as a string.
    def self.extract_response_text(response)
      case(response)
      when String
        response
      when Array
        response.join
      when Rack::Response
        response.body.join
      when Rack::File
        File.read(response.path)
      else
        response.to_s
      end
    end
    
    # Simple shared cache implementation
    class Cache
      # Initialize
      def initialize
        self.clear
      end

      # Either get the cached key or save the contents of the block
      #
      # @param Anything Hash can use as a key
      # @return Cached value
      def fetch(*key)
        @cache[key] ||= yield
      end

      # Whether the key is in the cache
      # 
      # @param Anything Hash can use as a key
      # @return [Boolean]
      def has_key?(key)
        @cache.has_key?(key)
      end

      # Get a specific key
      #
      # @param Anything Hash can use as a key
      # @return Cached value
      def get(key)
        @cache[key]
      end

      def keys
        @cache.keys
      end

      # Clear the entire cache
      def clear
        @cache = {}
      end

      # Set a specific key
      #
      # @param Anything Hash can use as a key
      # @param Cached value
      def set(key, value)
        @cache[key] = value
      end

      # Remove a specific key
      # @param Anything Hash can use as a key
      def remove(*key)
        @cache.delete(key)
      end
    end
  end
end