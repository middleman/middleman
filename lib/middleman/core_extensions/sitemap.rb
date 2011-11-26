require "active_support/core_ext/hash/deep_merge"
require 'find'

module Middleman::CoreExtensions::Sitemap
  class << self
    def registered(app)
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      ::Middleman::Sitemap::Template.cache.clear
    
      file_changed do |file|
        sitemap.touch_file(file)
      end
    
      file_deleted do |file|
        sitemap.remove_file(file)
      end
      
      super
    end
    
    def sitemap
      @sitemap ||= ::Middleman::Sitemap::Store.new(self)
    end
    
    # Keep a path from building
    def ignore(path)
      sitemap.ignore(path)
    end
    
    def reroute(url, target)
      sitemap.proxy(url, target)
    end
    
    def provides_metadata(matcher=nil, &block)
      @_provides_metadata ||= []
      @_provides_metadata << [block, matcher] if block_given?
      @_provides_metadata
    end
  end
end