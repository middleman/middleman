module Middleman::Sitemap::Extensions
  class Proxies
    
    def initialize(sitemap)
      @sitemap = sitemap
      @app     = @sitemap.app
      
      @proxy_paths = {}
      
      @app.class.delegate :proxy, :to => self
    end
    
    # Setup a proxy from a path to a target
    # @param [String] path
    # @param [String] target
    # @return [void]
    def proxy(path, target)
      @proxy_paths[normalize_path(path)] = normalize_path(target)
      @sitemap.rebuild_page_list!(:added_proxy)
    end
    
    # Update the main sitemap page list
    # @return [void]
    def manipulate_page_list!
      proxy_pages = @proxy_paths.map do |key, value|
        p = ::Middleman::Sitemap::Page.new(
          @sitemap,
          key
        )
        p.proxy_to(value)
        p
      end

      @sitemap.pages = @sitemap.pages.concat(proxy_pages)
    end
  end
end