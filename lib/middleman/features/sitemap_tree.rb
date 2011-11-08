module Middleman::Features::SitemapTree
  class << self
    def registered(app)
      app.helpers Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def sitemap_tree(regex=nil)
      @sitemap_tree_cache = {}
      
      key = regex.nil? "all" : regex
      
      if !@sitemap_tree_cache.has_key?(key)
        auto_hash = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }

        app.sitemap.all_paths.each do |path|
          next if !regex.nil? && !path.match(regex)
          sub = auto_hash
          path.split( "/" ).each{ |dir| sub[dir]; sub = sub[dir] }
        end
      
        @sitemap_tree_cache[key] = auto_hash
      end
      
      @sitemap_tree_cache[key]
    end
    
    def html_sitemap
      sitemap_tree(/\.html$/)
    end
  end
end
