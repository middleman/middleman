require 'rack/builder'
require 'rack/static'
require 'tilt'

module Middleman
  module MetaPages
    # Metadata pages to be served in preview, in order to present information about the Middleman
    # application and its configuration. Analogous to Firefox/Chrome's "about:" pages.
    #
    # Built using a ghetto little Rack web framework cobbled together because I didn't want to depend
    # on Sinatra or figure out how to host Middleman inside Middleman.
    class Application
      def initialize(middleman)
        # Hold a reference to the middleman application
        @middleman = middleman

        meta_pages = self
        @rack_app = Rack::Builder.new do
          # Serve assets from metadata/assets
          use Rack::Static, :urls => ["/assets"], :root => File.join(File.dirname(__FILE__), 'meta_pages')

          map '/' do
            run meta_pages.method(:index)
          end

          map '/sitemap' do
            run meta_pages.method(:sitemap)
          end
        end
      end

      def call(*args)
        @rack_app.call(*args)
      end
      
      # The index page
      def index(env)
        template('index.html.erb')
      end

      # Inspect the sitemap
      def sitemap(env)
        resources = @middleman.sitemap.resources(true)

        resource_tree = {}
        resources.each do |resource|
          branch = resource_tree
          path_parts = resource.path.split('/')
          path_parts[0...-1].each do |path_part|
            branch[path_part] ||= {}
            branch = branch[path_part]
          end
          branch[path_parts.last] = resource
        end

        template('sitemap.html.erb', :resource_tree => resource_tree)
      end

      private

      # Render a template with the given name and locals
      def template(template_name, locals={})
        template_path = File.join(File.dirname(__FILE__), 'meta_pages', 'templates', template_name)
        content = Tilt.new(template_path).render(RenderHelper.new, locals)
        response(content)
      end

      # Respond to an HTML request
      def response(content)
        [ 200, {"Content-Type" => "text/html"}, Array(content) ]
      end

      class RenderHelper
        def partial(partial_name, locals={})
          partial_path = File.join(File.dirname(__FILE__), 'meta_pages', 'templates', 'partials', partial_name)
          content = Tilt.new(partial_path).render(RenderHelper.new, locals)
        end
      end
    end
  end
end
