require "yaml"
require "tilt"

module Middleman::CoreExtensions::FrontMatter
  class << self
    def registered(app)
      app.extend ClassMethods
      
      ::Tilt::register RDiscountTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register RedClothTemplate,  'textile'
      ::Tilt::register ERBTemplate,       'erb', 'rhtml'
      ::Tilt::register ErubisTemplate,    'erb', 'rhtml', 'erubis'
      
      app.before do
        result = resolve_template(request.path_info, :raise_exceptions => false)
        if result
          full_file_path = "#{extensionless_path}.#{template_engine}"
          system_path = File.join(settings.views, full_file_path)
          data, content = app.parse_front_matter(File.read(system_path))
      
          %w(layout layout_engine).each do |opt|
            if data.has_key?(opt)
              options[opt.to_sym] = data.delete(opt)
            end
          end
      
          # Forward remaining data to helpers
          app.data_content("page", data)
        end
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def parse_front_matter(content)
      yaml_regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      if content =~ yaml_regex
        begin
          data = YAML.load($1)
        rescue => e
          puts "YAML Exception: #{e.message}"
        end
        
        content = content.split(yaml_regex).last
      end

      data ||= {}
      [data, content]
    end
  end
  
  module YamlAware
    def prepare
      options, @data = Middleman::Server.parse_front_matter(@data)
      super
    end
  end

  # MARKDOWN
  class RDiscountTemplate < ::Tilt::RDiscountTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  
  # TEXTILE
  class RedClothTemplate < ::Tilt::RedClothTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end

  # ERb
  class ERBTemplate < ::Tilt::ERBTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  
  class ErubisTemplate < ::Tilt::ErubisTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
end