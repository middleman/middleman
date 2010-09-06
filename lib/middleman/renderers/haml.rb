require "haml"

module Middleman
  module Haml  
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

class Middleman::Server
  helpers Middleman::Haml::Helpers
end