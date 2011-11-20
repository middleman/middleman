module Middleman
  class Cache
    def initialize
      @cache = {}
    end

    def fetch(*key)
      @cache[key] ||= yield
    end

    def clear
      @cache = {}
    end
    
    def set(key, value)
      @cache[key] = value
    end
    
    def remove(*key)
      @cache.delete(key) if @cache.has_key?(key)
    end
  end
end