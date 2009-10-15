module Middleman
  class Base
    def self.asset_url(path, prefix="", request=nil)
      base_url = File.join(self.http_prefix, prefix)
      path.include?("://") ? path : File.join(base_url, path)
    end
  end
  
  module Helpers
    def page_classes(*additional)
      path = request.path_info
      path << options.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')
  
      classes = []
      parts = path.split('.')[0].split('/')
      parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

      classes << "index" if classes.empty?
      classes += additional unless additional.empty?
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
      params = params.merge(:src => asset_url(path, options.images_dir))
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<img #{params} />"
    end

    def javascript_include_tag(path, params={})
      params = params.merge(:src => asset_url(path, options.js_dir), :type => "text/javascript")
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<script #{params}></script>"
    end

    def stylesheet_link_tag(path, params={})
      params[:rel] ||= "stylesheet"
      params = params.merge(:href => asset_url(path, options.css_dir), :type => "text/css")
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      "<link #{params} />"
    end
  end
end
