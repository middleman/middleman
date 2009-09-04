module Table
  include Haml::Filters::Base

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

def find_and_include_related_sass_file
  path = request.path_info.dup
  path << "index.html" if path.match(%r{/$})
  path.gsub!(%r{^/}, '')
  path.gsub!(File.extname(path), '')
  path.gsub!('/', '-')

  sass_file = File.join(File.basename(self.class.views), "stylesheets", "#{path}.sass")
  if File.exists? sass_file
    stylesheet_link_tag "stylesheets/#{path}.css"
  end
end

def link_to(title, url="#", params={})
  params.merge!(:href => url)
  params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
  %Q{<a #{params}>#{title}</a>}
end

def page_classes(*additional)
  path = request.path_info
  path << "index.html" if path.match(%r{/$})
  path.gsub!(%r{^/}, '')
  
  classes = []
  parts = path.split('.')[0].split('/')
  parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }

  classes << "index" if classes.empty?
  classes += additional unless additional.empty?
  classes.join(' ')
end

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

def asset_url(path)
  path.include?("://") ? path : "/#{path}"
end

def image_tag(path, options={})
  options[:alt] ||= ""
  capture_haml do
    haml_tag :img, options.merge(:src => asset_url(path))
  end
end

def javascript_include_tag(path, options={})
  capture_haml do
    haml_tag :script, options.merge(:src => asset_url(path), :type => "text/javascript")
  end
end

def stylesheet_link_tag(path, options={})
  options[:rel] ||= "stylesheet"
  capture_haml do
    haml_tag :link, options.merge(:href => asset_url(path), :type => "text/css")
  end
end

# Handle Sass errors
def sass_exception_string(e)
  e_string = "#{e.class}: #{e.message}"

  if e.is_a? Sass::SyntaxError
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