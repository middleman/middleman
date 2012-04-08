module Middleman::Sitemap::Extensions
  class Ignores
    
    def initialize(sitemap)
      @sitemap = sitemap
      @app     = @sitemap.app
      
      @ignored_callbacks = []
      
      @app.class.delegate :ignore, :to => self
    end
    
    # Ignore a path or add an ignore callback
    # @param [String, Regexp] path, path glob expression, or path regex
    # @return [void]
    def ignore(path=nil, &block)
      if path.is_a? Regexp
        @ignored_callbacks << Proc.new {|p| p =~ path }
      elsif path.is_a? String
        path_clean = @sitemap.normalize_path(path)
        if path_clean.include?("*") # It's a glob
          @ignored_callbacks << Proc.new {|p| File.fnmatch(path_clean, p) }
        else
          @ignored_callbacks << Proc.new {|p| p == path_clean }
        end
      elsif block_given?
        @ignored_callbacks << block
      end
      
      @sitemap.rebuild_page_list!(:added_ignore_rule)
    end
    
    # Whether a path is ignored
    # @param [String] path
    # @return [Boolean]
    def ignored?(path)
      path_clean = @sitemap.normalize_path(path)
      @ignored_callbacks.any? { |b| b.call(path_clean) }
    end
    
    # Update the main sitemap page list
    # @return [void]
    def manipulate_page_list!
      @sitemap.pages = @sitemap.pages.reject do |page|
        ignored?(page.path) || ignored?(page.source_file)
      end
    end
  end
end