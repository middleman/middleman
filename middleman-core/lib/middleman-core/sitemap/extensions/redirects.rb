require 'middleman-core/sitemap/resource'
require 'middleman-core/contracts'

module Middleman
  module Sitemap
    module Extensions
      # Manages the list of proxy configurations and manipulates the sitemap
      # to include new resources based on those configurations
      class Redirects < ConfigExtension
        self.resource_list_manipulator_priority = 0

        # Expose `redirect`
        expose_to_config :redirect

        RedirectDescriptor = Struct.new(:path, :to, :template) do
          def execute_descriptor(app, resource_list)
            r = RedirectResource.new(
              app.sitemap,
              path,
              to
            )
            r.output = template if template

            resource_list.add! r
          end
        end

        # Setup a redirect from a path to a target
        # @param [String] path
        # @param [Hash] opts The :to value gives a target path
        Contract String, { to: Or[String, ::Middleman::Sitemap::Resource] }, Maybe[Proc] => RedirectDescriptor
        def redirect(path, options_hash = {}, &block)
          RedirectDescriptor.new(path, options_hash[:to], block_given? ? block : nil)
        end
      end

      class RedirectResource < ::Middleman::Sitemap::Resource
        Contract Maybe[Proc]
        attr_accessor :output

        def initialize(store, path, target)
          @request_path = target

          super(store, path)
        end

        Contract Bool
        def template?
          true
        end

        Contract Args[Any] => String
        def render(*)
          url = ::Middleman::Util.url_for(@store.app, @request_path,
                                          relative: false,
                                          find_resource: true)

          if output
            output.call(path, url)
          else
            <<-END
              <html>
                <head>
                  <link rel="canonical" href="#{url}" />
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

        Contract Bool
        def ignored?
          false
        end
      end
    end
  end
end
