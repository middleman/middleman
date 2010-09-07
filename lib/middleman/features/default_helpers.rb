module Middleman::Features::DefaultHelpers
  class << self
    def registered(app)
      app.helpers Middleman::Features::DefaultHelpers::Helpers
    end
    alias :included :registered
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
      less_file = File.join(self.class.views, self.class.css_dir, "#{path}.css.less")
    
      if File.exists?(css_file) || File.exists?(sass_file) || File.exists?(scss_file) || File.exists?(less_file)
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
    
    # Padrino's asset handling needs to pass through ours
    def asset_path(kind, source)
       return source if source =~ /^http/
       asset_folder  = case kind
         when :css    then settings.css_dir
         when :js     then settings.js_dir
         when :images then settings.images_dir
         else kind.to_s
       end
       source = source.to_s.gsub(/\s/, '')
       ignore_extension = (asset_folder.to_s == kind.to_s) # don't append extension
       source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
       result_path   = source if source =~ %r{^/} # absolute path
       result_path ||= asset_url(source, asset_folder)
       timestamp = asset_timestamp(result_path)
       "#{result_path}#{timestamp}"
     end
  end
end