module Middleman
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
      @cache.delete(key) if @cache.has_key?(key)
    end
  end
end