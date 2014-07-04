require 'middleman-core/sitemap/resource'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Redirects
        def initialize(app)
          @app = app
          @app.add_to_config_context :redirect, &method(:create_redirect)

          @redirects = {}
        end

        # Setup a redirect from a path to a target
        # @param [String] path
        # @param [Hash] opts The :to value gives a target path
        def create_redirect(path, opts={}, &block)
          opts[:template] = block if block_given?

          @redirects[path] = opts

          @app.sitemap.rebuild_resource_list!(:added_redirect)
        end

        # Update the main sitemap resource list
        # @return [void]
        def manipulate_resource_list(resources)
          resources + @redirects.map do |path, opts|
            r = RedirectResource.new(
              @app.sitemap,
              path,
              opts[:to]
            )
            r.output = opts[:template] if opts[:template]
            r
          end
        end
      end

      class RedirectResource < ::Middleman::Sitemap::Resource
        attr_accessor :output

        def initialize(store, path, target)
          @request_path = target

          super(store, path)
        end

        def template?
          true
        end

        def render(*)
          url = ::Middleman::Util.url_for(@store.app, @request_path,
                                          relative: false,
                                          find_resource: true
          )

          if output
            output.call(path, url)
          else
            <<-END
              <html>
                <head>
                  <meta http-equiv=refresh content="0; url=#{url}" />
                  <meta name="robots" content="noindex,follow" />
                  <meta http-equiv="cache-control" content="no-cache" />
                </head>
                <body>
                </body>
              </html>
            END
          end
        end

        def ignored?
          false
        end
      end
    end
  end
end
