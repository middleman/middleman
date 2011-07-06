require "padrino-helpers"

module Middleman::CoreExtensions::DefaultHelpers
  class << self
    def registered(app)
      # Use Padrino Helpers
      app.register Padrino::Helpers
      
      # Middleman Helpers
      app.helpers Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def auto_stylesheet_link_tag(separator="/")
      auto_tag(:css, separator) do |path|
        stylesheet_link_tag path
      end
    end
    
    def auto_javascript_include_tag(separator="/")
      auto_tag(:js, separator) do |path|
        javascript_include_tag path
      end
    end

    def auto_tag(asset_ext, separator="/", asset_dir=nil)
      if asset_dir.nil?
        asset_dir = case asset_ext
          when :js  then self.class.js_dir
          when :css then self.class.css_dir
        end
      end
      path = request.path_info.dup
      # If the basename of the request as no extension, assume we are serving a
      # directory and join index_file to the path.
      path = File.join(path, self.class.index_file) if File.extname(path).empty?
      path = path.gsub(%r{^/}, '')
      path = path.gsub(File.extname(path), ".#{asset_ext}")
      path = path.gsub("/", separator)

      view = File.join(self.class.views, asset_dir, path)
      yield path if File.exists?(view) or Dir["#{view}.*"].any?
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
       ignore_extension = (kind == :images) # don't append extension
       source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
       result_path   = source if source =~ %r{^/} # absolute path
       result_path ||= asset_url(source, asset_folder)
       timestamp = asset_timestamp(result_path)
       "#{result_path}#{timestamp}"
     end
  end
end
