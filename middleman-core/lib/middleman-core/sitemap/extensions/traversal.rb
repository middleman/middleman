module Middleman::Sitemap::Extensions
  module Traversal
    # This page's parent page
    # @return [Middleman::Sitemap::Page, nil]
    def parent
      parts = path.split("/")
      if path.include?(app.index_file)
        parts.pop
      end
  
      return nil if parts.length < 1
  
      parts.pop
      parts.push(app.index_file)
  
      parent_path = "/" + parts.join("/")
  
      if store.exists?(parent_path)
        store.page(parent_path)
      else
        nil
      end
    end

    # This page's child pages
    # @return [Array<Middleman::Sitemap::Page>]
    def children
      return [] unless directory_index?

      if eponymous_directory?
        base_path = eponymous_directory_path
        prefix    = %r|^#{base_path.sub("/", "\\/")}|
      else
        base_path = path.sub("#{app.index_file}", "")
        prefix    = %r|^#{base_path.sub("/", "\\/")}|
      end

      store.pages.select do |sub_page|
        if sub_page.path == self.path || sub_page.path !~ prefix
          false
        else
          inner_path = sub_page.path.sub(prefix, "")
          parts = inner_path.split("/")
          if parts.length == 1
            true
          elsif parts.length == 2
            parts.last == app.index_file
          else
            false
          end
        end
      end
    end

    # This page's sibling pages
    # @return [Array<Middleman::Sitemap::Page>]
    def siblings
      return [] unless parent
      parent.children.reject { |p| p == self }
    end

  end
end