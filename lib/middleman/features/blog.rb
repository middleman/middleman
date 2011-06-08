module Middleman
  module Features
    module Blog
      class << self
        def registered(app)
          # Depend on FrontMatter
          app.activate Middleman::Features::FrontMatter
          
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
              app.set :blog_summary_separator, "READMORE"
            end

            if !app.settings.respond_to? :blog_layout_engine
              app.set :blog_layout_engine, "erb"
            end
            
            if !app.settings.respond_to? :blog_article_template
              app.set :blog_article_template, "article_template"
            end
            
            $stderr.puts "== Blog: #{app.settings.blog_permalink}"
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
          
          # Handle /archives/
          require "middleman/builder"
          Middleman::Builder.after_run "blog_archives" do
            # source_paths << File.expand_path(File.join(File.dirname(__FILE__), "middleman-slickmap", "templates"))
            # tilt_template "slickmap.html.haml", File.join(Middleman::Server.build_dir, sitemap_url), { :force => true }
          end
          
        end
        alias :included :registered
      end
      
      module Helpers
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