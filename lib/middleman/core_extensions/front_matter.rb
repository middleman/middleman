require "yaml"
require "tilt"

module Middleman::CoreExtensions::FrontMatter
  class << self
    def registered(app)
      app.extend ClassMethods
      
      ::Tilt::register RDiscountTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register RedcarpetTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register MarukuTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register KramdownTemplate, 'markdown', 'mkd', 'md'
      app.set :markdown_engine, MarukuTemplate
      
      ::Tilt::register RedClothTemplate,  'textile'
      ::Tilt.prefer(RedClothTemplate)
      
      ::Tilt::register ERBTemplate,       'erb', 'rhtml'
      ::Tilt.prefer(ERBTemplate)
      
      ::Tilt::register SlimTemplate,      'slim'
      ::Tilt.prefer(SlimTemplate)
      
      ::Tilt::register HamlTemplate,      'haml'
      ::Tilt.prefer(HamlTemplate)
      
      app.after_configuration do
        app.before_processing do
          request_path = request.path_info.gsub("%20", " ")
          result = resolve_template(request_path, :raise_exceptions => false)
        
          if result && Tilt.mappings.has_key?(result[1].to_s)
            extensionless_path, template_engine = result
            full_file_path = "#{extensionless_path}.#{template_engine}"
            system_path = File.join(settings.views, full_file_path)
            data, content = app.parse_front_matter(File.read(system_path))
  
            request['custom_options'] = {}
            %w(layout layout_engine).each do |opt|
              if data.has_key?(opt)
                request['custom_options'][opt.to_sym] = data.delete(opt)
              end
            end
  
            # Forward remaining data to helpers
            app.data_content("page", data)
          end
        
          true
        end
      end
    end
    alias :included :registered
    
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
  
  module ClassMethods
    def parse_front_matter(content)
      Middleman::CoreExtensions::FrontMatter.parse_front_matter(content)
    end
  end
  
  module YamlAware
    def prepare
      options, @data = Middleman::CoreExtensions::FrontMatter.parse_front_matter(@data)
      super
    end
  end

  class RDiscountTemplate < ::Tilt::RDiscountTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  class RedcarpetTemplate < ::Tilt::RedcarpetTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  class MarukuTemplate < ::Tilt::MarukuTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  class RedClothTemplate < ::Tilt::RedClothTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  class KramdownTemplate < ::Tilt::KramdownTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
 
  class ERBTemplate < ::Tilt::ERBTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end

  class HamlTemplate < ::Tilt::HamlTemplate
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
  
  class SlimTemplate < ::Slim::Template
    include Middleman::CoreExtensions::FrontMatter::YamlAware
  end
end