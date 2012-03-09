require 'middleman-core/vendor/padrino-helpers-0.10.5/lib/padrino-helpers'

# Built-in helpers
module Middleman::CoreExtensions::DefaultHelpers
  
  # Extension registered
  class << self
    # @private
    def registered(app)
      app.helpers ::Padrino::Helpers::OutputHelpers
      app.helpers ::Padrino::Helpers::TagHelpers
      app.helpers ::Padrino::Helpers::AssetTagHelpers
      app.helpers ::Padrino::Helpers::FormHelpers
      app.helpers ::Padrino::Helpers::FormatHelpers
      app.helpers ::Padrino::Helpers::RenderHelpers
      app.helpers ::Padrino::Helpers::NumberHelpers
      app.helpers ::Padrino::Helpers::TranslationHelpers
      
      app.helpers Helpers
      
      app.ready do
        ::I18n.load_path += Dir["#{File.join(root, 'locales','*.yml')}"]
        ::I18n.load_path += Dir["#{File.dirname(__FILE__)}/../vendor/padrino-helpers-0.10.5/lib/padrino-helpers/locale/*.yml"]
      end
    end
    alias :included :registered
  end
  
  # The helpers
  module Helpers
    # Output a stylesheet link tag based on the current path
    #
    # @param [String] separator How to break up path in parts
    # @return [String]
    def auto_stylesheet_link_tag(separator="/")
      auto_tag(:css, separator) do |path|
        stylesheet_link_tag path
      end
    end
    
    # Output a javascript tag based on the current path
    #
    # @param [String] separator How to break up path in parts
    # @return [String]
    def auto_javascript_include_tag(separator="/")
      auto_tag(:js, separator) do |path|
        javascript_include_tag path
      end
    end

    # Output a stylesheet link tag based on the current path
    #
    # @param [Symbol] asset_ext The type of asset
    # @param [String] separator How to break up path in parts
    # @param [String] asset_dir Where to look for assets
    # @return [void]
    def auto_tag(asset_ext, separator="/", asset_dir=nil)
      if asset_dir.nil?
        asset_dir = case asset_ext
          when :js  then js_dir
          when :css then css_dir
        end
      end
      
      # If the basename of the request as no extension, assume we are serving a
      # directory and join index_file to the path.
      path = full_path(current_path.dup)
      path = path.sub(%r{^/}, '')
      path = path.gsub(File.extname(path), ".#{asset_ext}")
      path = path.gsub("/", separator)
        
      yield path if sitemap.exists?(File.join(asset_dir, path))
    end

    # Generate body css classes based on the current path
    #
    # @return [String]
    def page_classes
      path = current_path.dup
      path << index_file if path.match(%r{/$})
      path = path.gsub(%r{^/}, '')
  
      classes = []
      parts = path.split('.')[0].split('/')
      parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }
      
      classes.join(' ')
    end
    
    # Get the path of a file of a given type
    # 
    # @param [Symbol] kind The type of file
    # @param [String] source The path to the file
    # @return [String]
    def asset_path(kind, source)
       return source if source =~ /^http/
       asset_folder  = case kind
         when :css    then css_dir
         when :js     then js_dir
         when :images then images_dir
         else kind.to_s
       end
       source = source.to_s.gsub(/\s/, '')
       ignore_extension = (kind == :images) # don't append extension
       source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
       result_path   = source if source =~ %r{^/} # absolute path
       result_path ||= asset_url(source, asset_folder)
       "#{result_path}"
     end
  end
end
