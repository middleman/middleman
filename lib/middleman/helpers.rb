module Middleman
  class Base
    def self.asset_url(path, prefix="", request=nil)
      path.include?("://") ? path : File.join(self.http_prefix || "/", prefix, path)
    end
  end
  
  module Helpers
    def haml_partial(name, options = {})
      haml name.to_sym, options.merge(:layout => false)
    end
    
    def auto_stylesheet_link_tag(separator="/")
      path = request.path_info.dup
      path << self.class.index_file if path.match(%r{/$})
      path = path.gsub(%r{^/}, '')
      path = path.gsub(File.extname(path), '')
      path = path.gsub("/", separator)

      css_file = File.join(self.class.public, self.class.css_dir, "#{path}.css")
      sass_file = File.join(self.class.views, self.class.css_dir, "#{path}.css.sass")
    
      if File.exists?(css_file) || File.exists?(sass_file)
        stylesheet_link_tag "#{path}.css"
      end
    end
    
    def page_classes
      path = request.path_info.dup
      path << settings.index_file if path.match(%r{/$})
      path = path.gsub(%r{^/}, '')
  
      classes = []
      parts = path.split('.')[0].split('/')
      parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }
      
      classes.join(' ')
    end
    
    def asset_url(path, prefix="")
      self.class.asset_url(path, prefix, request)
    end
    
    def link_to(title, url="#", params={})
      params.merge!(:href => url)
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      %Q{<a #{params}>#{title}</a>}
    end

    def image_tag(path, params={})
      params[:alt] ||= ""
      prefix = settings.http_images_path rescue settings.images_dir
      params = params.merge(:src => asset_url(path, prefix))
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<img #{params} />"
    end

    def javascript_include_tag(path, params={})
      params = params.merge(:src => asset_url(path, settings.js_dir), :type => "text/javascript")
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<script #{params}></script>"
    end

    def stylesheet_link_tag(path, params={})
      params[:rel] ||= "stylesheet"
      params = params.merge(:href => asset_url(path, settings.css_dir), :type => "text/css")
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<link #{params} />"
    end
  end
end
