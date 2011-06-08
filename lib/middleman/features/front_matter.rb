require "yaml"
require "tilt"

module Middleman::Features::FrontMatter
  class << self
    def registered(app)
      app.extend ClassMethods
      
      ::Tilt::register MarukuTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register KramdownTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register BlueClothTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register RedcarpetTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register RDiscountTemplate, 'markdown', 'mkd', 'md'
      ::Tilt::register RedClothTemplate, 'textile'
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
  class MarukuTemplate < ::Tilt::MarukuTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
  
  class KramdownTemplate < ::Tilt::KramdownTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
  
  class BlueClothTemplate < ::Tilt::BlueClothTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
  
  class RedcarpetTemplate < ::Tilt::RedcarpetTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
  
  class RDiscountTemplate < ::Tilt::RDiscountTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
  
  # TEXTILE
  class RedClothTemplate < ::Tilt::RedClothTemplate
    include Middleman::Features::FrontMatter::YamlAware
  end
end