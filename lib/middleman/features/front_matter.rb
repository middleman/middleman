require "yaml"
require "tilt"

module Middleman::Features::FrontMatter
  class << self
    def registered(app)
      app.extend ClassMethods
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
end

# class FrontMatter < Tilt::RDiscountTemplate
#   def prepare
#     options, @data = Middleman::Server.parse_front_matter(@data)
#     super
#   end
# end
# 
# Tilt.register 'markdown', FrontMatter