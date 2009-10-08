begin
  require 'slickmap'
  ::Compass.configure_sass_plugin!
rescue LoadError
  puts "Slickmap not available. Install it with: gem install compass-slickmap"
end

if Middleman::Base.environment == "build"
  Middleman::Builder.template :slickmap, "sitemap.html", "sitemap.html"
end

Entry = Struct.new(:dir, :children)

class Middleman::Base
  def build_sitemap(&block)    
    @@utility = []
    [recurse_sitemap(Middleman::Base.views, &block), @@utility]
  end
  
  def recurse_sitemap(path, &block)
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
          @@utility << e.gsub(Middleman::Base.views + "/", '')
        end
      end
    end

    entry
  end
  
  helpers do
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
  
  get '/sitemap.html' do
    # Return :utility to put it util top menu. False to ignore
    @tree, @utility = build_sitemap do |file_name|
      :valid
    end
    haml :sitemap, :layout => false
  end

  use_in_file_templates!
end

__END__

@@ sitemap
!!!
%html{ :xmlns => "http://www.w3.org/1999/xhtml" }
  %head
    %meta{ :content => "text/html; charset=utf-8", "http-equiv" => "Content-type" }
    %title Sitemap
    %style{ :type => "text/css" }
      :sass
        @import slickmap.sass
        +slickmap
    :javascript
      window.onload = function() {
        document.getElementById('primaryNav').className = "col" + document.querySelectorAll("#primaryNav > li:not(#home)").length;
      };

  %body
    .logo
      %h1= @project_name || "Sitemap"
      - if @project_subtitle
        %h2= @project_subtitle
    
      - if @utility.length > 0
        %ul#utilityNav
          - @utility.each do |u|
            %li= link_to u, u
    
    %ul#primaryNav
      - sitemap_node(@tree, true)