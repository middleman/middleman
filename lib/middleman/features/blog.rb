require "rdiscount"

module Middleman
  module Features
    module Blog
      class << self
        def registered(app)          
          # Include helpers
          app.helpers Middleman::Features::Blog::Helpers
          
          app.after_feature_init do
            if !app.settings.respond_to? :blog_permalink
              app.set :blog_permalink, "/:year/:month/:day/:title.html"
            end
            
            if !app.settings.respond_to? :blog_layout
              app.set :blog_layout, "layout"
            end
            
            if !app.settings.respond_to? :blog_summary_separator
              app.set :blog_summary_separator, /READMORE/
            end
            
            if !app.settings.respond_to? :blog_summary_length
              app.set :blog_summary_length, 250
            end

            if !app.settings.respond_to? :blog_layout_engine
              app.set :blog_layout_engine, "erb"
            end

            if !app.settings.respond_to? :blog_index_template
              app.set :blog_index_template, "index_template"
            end
            
            if !app.settings.respond_to? :blog_article_template
              app.set :blog_article_template, "article_template"
            end
            
            $stderr.puts "== Blog: #{app.settings.blog_permalink}"
            
            articles_glob = File.join(app.views, app.settings.blog_permalink.gsub(/(:\w+)/, "*") + ".*")
            
            articles = Dir[articles_glob].map do |article|
              template_content = File.read(article)
              data, content = parse_front_matter(template_content)
              data["date"] = Date.parse(data["date"])
              
              yaml_regex = /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
              data["raw"]  = template_content.split(yaml_regex).last
              data["url"] = article.gsub(app.views, "").split(".html").first + ".html"
              
              all_content = Tilt.new(article).render              
              data["body"] = all_content.gsub!(app.settings.blog_summary_separator, "")
              
              sum = if data["raw"] =~ app.settings.blog_summary_separator
                data["raw"].split(app.settings.blog_summary_separator).first
              else                data["raw"].match(/(.{1,#{app.settings.blog_summary_length}}.*?)(\n|\Z)/m).to_s
              end
              
              engine = RDiscount.new(sum)
              data["summary"] = engine.to_html
              data
            end.sort { |a, b| b["date"] <=> a["date"] }  
            
            app.data_content("blog", { :articles => articles })
            
            app.get(app.settings.blog_permalink) do
              options = {}
              options[:layout] = settings.blog_layout
              options[:layout_engine] = settings.blog_layout_engine
              
              extensionless_path, template_engine = resolve_template(request.path)

              full_file_path = "#{extensionless_path}.#{template_engine}"
              system_path = File.join(settings.views, full_file_path)
              data, content = self.class.parse_front_matter(File.read(system_path))

              # Forward remaining data to helpers
              self.class.data_content("page", data)
              
              output = render(request.path, options)
              
              # No need for separator on permalink page
              output.gsub!(settings.blog_summary_separator, "")
              
              status 200
              output
            end
          end
          
        end
        alias :included :registered
      end
      
      module Helpers
        def is_blog_article?
          !current_article_title.blank?
        end
        
        def blog_title
        end
        
        def current_article_date
          DateTime.parse(current_article_metadata.date)
        end
        
        def current_article_title
          current_article_metadata.title
        end
        
        def current_article_metadata
          data.page
        end
      end
    end
  end
end