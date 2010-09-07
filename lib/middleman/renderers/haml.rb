require "haml"

module Middleman
  module Renderers
    module Haml
      class << self
        def registered(app)
          app.helpers Middleman::Renderers::Haml::Helpers
        end
        alias :included :registered
      end
      
      module Helpers
        def haml_partial(name, options = {})
          partial(name, options)
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
end