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
      super

      file_changed %r{^source/} do |file|
        sitemap.touch_file(file)
      end

      file_deleted %r{^source/} do |file|
        sitemap.remove_file(file)
      end
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
    
    def provides_metadata_for_path(matcher=nil, &block)
      @_provides_metadata_for_path ||= []
      @_provides_metadata_for_path << [block, matcher] if block_given?
      @_provides_metadata_for_path
    end
  end
end