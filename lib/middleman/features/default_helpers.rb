class Middleman::Features::DefaultHelpers
  def initialize(app, config)
    Middleman::Server.helpers Helpers
  end
  
  module Helpers
    def auto_stylesheet_link_tag(separator="/")
      path = request.path_info.dup
      path << self.class.index_file if path.match(%r{/$})
      path = path.gsub(%r{^/}, '')
      path = path.gsub(File.extname(path), '')
      path = path.gsub("/", separator)

      css_file = File.join(self.class.public, self.class.css_dir, "#{path}.css")
      sass_file = File.join(self.class.views, self.class.css_dir, "#{path}.css.sass")
      scss_file = File.join(self.class.views, self.class.css_dir, "#{path}.css.scss")
    
      if File.exists?(css_file) || File.exists?(sass_file) || File.exists?(scss_file)
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
      Middleman::Assets.get_url(path, prefix, request)
    end
    
    def link_to(title, url="#", params={})
      params.merge!(:href => url)
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      %Q{<a #{params}>#{title}</a>}
    end

    def image_tag(path, params={})
      params[:alt] ||= ""
      prefix = settings.http_images_path rescue settings.images_dir
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      params << " " if params.length > 0
      "<img src=\"#{asset_url(path, prefix)}\" #{params}/>"
    end

    def javascript_include_tag(path, params={})
      path = path.to_s
      path << ".js" unless path =~ /\.js$/
      
      params.delete(:type)
      params.delete(:src)
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      params = " " + params if params.length > 0
      "<script type=\"text/javascript\" src=\"#{asset_url(path, settings.js_dir)}\"#{params}></script>"
    end

    def stylesheet_link_tag(path, params={})
      path = path.to_s
      path << ".css" unless path =~ /\.css$/
      
      params.delete(:type)
      params.delete(:rel)
      params.delete(:href)
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      params << " " if params.length > 0
      "<link type=\"text/css\" rel=\"stylesheet\" href=\"#{asset_url(path, settings.css_dir)}\" #{params}/>"
    end
  end
end

Middleman::Features.register :default_helpers, Middleman::Features::DefaultHelpers, { :auto_enable => true }