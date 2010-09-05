module Middleman

  module Renderers
    @@render_method_for_template_types = {}
  
    def self.register(method_name, template_type)
      @@render_method_for_template_types[template_type.to_s] = method_name
    end
  
    def self.get_method(template_path)
      template_type = Tilt[template_path].to_s
      @@render_method_for_template_types[template_type]
    end

  end
end

# Types built into Sinatra
Middleman::Renderers.register(:less,    Tilt::LessTemplate)
Middleman::Renderers.register(:haml,    Tilt::HamlTemplate)
Middleman::Renderers.register(:builder, Tilt::BuilderTemplate)
Middleman::Renderers.register(:erb,     Tilt::ERBTemplate)

%w(haml
   sass
   coffee).each { |renderer| require "middleman/renderers/#{renderer}" }