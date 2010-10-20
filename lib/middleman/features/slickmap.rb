Entry = Struct.new(:dir, :children)

module Middleman::Features::Slickmap
  class << self
    def registered(app)
      require 'slickmap'

      @sitemap_url = "sitemap.html"
      @sitemap_url = app.sitemap_url if app.respond_to?(:slickmap_url)

      if app.environment == :build
        Middleman::Builder.template :slickmap, @sitemap_url, @sitemap_url
      end

      app.helpers do
        def sitemap_node(n, first=false)
          if n.children.length < 1
            if !first && File.extname(n.dir).length > 0
              haml_tag :li do
                path = n.dir.gsub(self.class.views, '')
                haml_concat link_to(File.basename(path), path)
              end
            end
          else  
            haml_tag(:li, :id => first ? "home" : nil) do
              if first
                haml_concat link_to("Homepage", "/" + self.class.index_file)
              else
                # we are a dir
                index = n.children.find { |c| c.dir.include?(self.class.index_file) }
                haml_concat link_to(index.dir.gsub(self.class.views + "/", '').gsub("/" + File.basename(index.dir), '').capitalize, index.dir.gsub(self.class.views, ''))
              end

              other_children = n.children.select { |c| !c.dir.include?(self.class.index_file) }
              if other_children.length > 0
                if first
                  other_children.each { |i| sitemap_node(i) }
                else
                  haml_tag :ul do
                    other_children.each { |i| sitemap_node(i) }
                  end
                end
              end
            end  
          end
        end
      end

      app.get "/#{@sitemap_url}" do
        # Return :utility to put it util top menu. False to ignore
        @tree, @utility = Middleman::Features::Slickmap.build_sitemap do |file_name|
          :valid
        end

        haml "template.html".to_sym, :layout => false, :views => File.expand_path(File.join(File.dirname(__FILE__), "slickmap"))
      end
    end
    alias :included :registered
  end
  
  def self.build_sitemap(&block)    
    @@utility = []
    [recurse_sitemap(Middleman::Server.views, &block), @@utility]
  end

  def self.recurse_sitemap(path, &block)
    bad_ext = path.split('.html')[1]
    path = path.gsub(bad_ext, '') if bad_ext
    entry = Entry.new(path, [])

    #no "." or ".." dirs
    Dir[File.join(path, "*")].each do |e|
      next if !File.directory?(e) && !e.include?(".html")
      if File.directory?(e)
        entry.children << recurse_sitemap(e, &block)
      elsif block_given?
        how_to_handle = block.call(e)
        if how_to_handle == :valid
          entry.children << recurse_sitemap(e, &block)
        elsif how_to_handle == :utility
          bad_ext = e.split('.html')[1]
          e = e.gsub(bad_ext, '') if bad_ext
          @@utility << e.gsub(Middleman::Server.views + "/", '')
        end
      end
    end

    entry
  end
end
