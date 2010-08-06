require "haml"

module Middleman
  module Haml
    module Renderer
      def self.included(base)
        base.supported_formats << "haml"
        base.helpers Middleman::Haml::Helpers
      end
    
      def render_path(path, layout)
        if template_exists?(path, :haml)
          result = nil
          begin
            layout = false if File.extname(path) == ".xml"
            result = haml(path.to_sym, :layout => layout, :ugly => Middleman::Base.enabled?(:ugly_haml))
          rescue ::Haml::Error => e
            result = "Haml Error: #{e}"
            result << "<pre>Backtrace: #{e.backtrace.join("\n")}</pre>"
          end
          result
        else
          super
        end
      end
    end
  
    module Helpers
      def haml_partial(name, options = {})
        item_name = name.to_sym
        counter_name = "#{name}_counter".to_sym
        if collection = options.delete(:collection)
          collection.enum_for(:each_with_index).collect do |item,index|
            haml_partial name, options.merge(:locals => {item_name => item, counter_name => index+1})
          end.join
        elsif object = options.delete(:object)
          haml_partial name, options.merge(:locals => {item_name => object, counter_name => nil})
        else
          haml "_#{name}".to_sym, options.merge(:layout => false)
        end
      end
    end
  
    module Table
      include ::Haml::Filters::Base

      def render(text)
        output = '<div class="table"><table cellspacing="0" cellpadding="0">'
        line_num = 0
        text.each_line do |line|
          line_num += 1
          next if line.strip.empty?
          output << %Q{<tr class="#{(line_num % 2 == 0) ? "even" : "odd" }#{(line_num == 1) ? " first" : "" }">}

          columns = line.split("|").map { |p| p.strip }
          columns.each_with_index do |col, i|
            output << %Q{<td class="col#{i+1}">#{col}</td>}
          end

          output << "</tr>"
        end
        output + "</table></div>"
      end
    end
  end
end

class Middleman::Base
  include Middleman::Haml::Renderer
end