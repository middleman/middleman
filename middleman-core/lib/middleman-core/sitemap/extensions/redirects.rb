require 'middleman-core/sitemap/resource'
require 'middleman-core/contracts'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Redirects < Extension
        def initialize(app, config={}, &block)
          super

          @app.add_to_config_context(:redirect, &method(:create_redirect))

          @redirects = {}
        end

        # Setup a redirect from a path to a target
        # @param [String] path
        # @param [Hash] opts The :to value gives a target path
        Contract String, ({ to: Or[String, IsA['Middleman::Sitemap::Resource']] }), Proc => Any
        def create_redirect(path, opts={}, &block)
          opts[:template] = block if block_given?

          @redirects[path] = opts

          @app.sitemap.rebuild_resource_list!(:added_redirect)
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
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
        Contract None => Maybe[Proc]
        attr_accessor :output

        def initialize(store, path, target)
          @request_path = target

          super(store, path)
        end

        Contract None => Bool
        def template?
          true
        end

        Contract Args[Any] => String
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

        Contract None => Bool
        def ignored?
          false
        end
      end
    end
  end
end
