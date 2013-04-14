require 'rack/builder'
require 'rack/static'
require 'tilt'
require 'middleman-core/meta_pages/sitemap_tree'
require 'middleman-core/meta_pages/config_setting'

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

          map '/config' do
            run meta_pages.method(:config)
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
        resources = @middleman.inst.sitemap.resources(true)

        sitemap_tree = SitemapTree.new

        resources.each do |resource|
          sitemap_tree.add_resource resource
        end

        template('sitemap.html.erb', :sitemap_tree => sitemap_tree)
      end

      # Inspect configuration
      def config(env)
        global_config = @middleman.inst.config.all_settings.map {|c| ConfigSetting.new(c) }
        extension_config = Hash[@middleman.inst.extensions.map do |ext_name, extension|
                                  opts = if extension.is_a?(::Middleman::Extension)
                                           extension.options.all_settings.map {|c| ConfigSetting.new(c) }
                                         else 
                                           nil
                                         end
                                  [ext_name, opts]
                                end]

        template('config.html.erb', 
                 :global_config => global_config,
                 :extension_config => extension_config, 
                 :registered_extensions => Middleman::Extensions.registered.dup)
      end

      private

      # Render a template with the given name and locals
      def template(template_name, locals={})
        template_path = File.join(File.dirname(__FILE__), 'meta_pages', 'templates', template_name)
        content = Tilt.new(template_path).render(nil, locals)
        response(content)
      end

      # Respond to an HTML request
      def response(content)
        [ 200, {"Content-Type" => "text/html"}, Array(content) ]
      end
    end
  end
end
