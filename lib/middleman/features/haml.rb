require 'haml'

module Middleman
  module Haml
    def self.included(base)
      base.supported_formats << "haml"
      base.helpers Middleman::HamlHelpers
    end
    
    def render_path(path)
      if template_exists?(path, :haml)
        result = nil
        begin
          result = haml(path.to_sym, :layout => File.extname(path) != ".xml")
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
  
  module HamlHelpers
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
  
  module Sass  
    def self.included(base)
      base.supported_formats << "sass"
    end
  
    def render_path(path)
      if template_exists?(path, :sass)
        begin
          static_version = options.public + request.path_info
          send_file(static_version) if File.exists? static_version

          location_of_sass_file = options.environment == "build" ? "build" : "views"
          css_filename = File.join(Dir.pwd, location_of_sass_file) + request.path_info
          sass(path.to_sym, Compass.sass_engine_options.merge({ :css_filename => css_filename }))
        rescue Exception => e
          sass_exception_string(e)
        end
      else
        super
      end
    end
  
    # Handle Sass errors
    def sass_exception_string(e)
      e_string = "#{e.class}: #{e.message}"

      if e.is_a? ::Sass::SyntaxError
        e_string << "\non line #{e.sass_line}"

        if e.sass_filename
          e_string << " of #{e.sass_filename}"

          if File.exists?(e.sass_filename)
            e_string << "\n\n"

            min = [e.sass_line - 5, 0].max
            begin
              File.read(e.sass_filename).rstrip.split("\n")[
                min .. e.sass_line + 5
              ].each_with_index do |line, i|
                e_string << "#{min + i + 1}: #{line}\n"
              end
            rescue
              e_string << "Couldn't read sass file: #{e.sass_filename}"
            end
          end
        end
      end
      <<END
/*
#{e_string}

Backtrace:\n#{e.backtrace.join("\n")}
*/
body:before {
  white-space: pre;
  font-family: monospace;
  content: "#{e_string.gsub('"', '\"').gsub("\n", '\\A ')}"; }
END
    end
  end
end

class Middleman::Base
  include Middleman::Haml
  include Middleman::Sass
end