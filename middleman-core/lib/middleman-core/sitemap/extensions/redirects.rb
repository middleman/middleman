module Middleman
  module Sitemap
    module Extensions
      module Redirects
        # Setup extension
        class << self
          # Once registered
          def registered(app)
            # Include methods
            app.send :include, InstanceMethods
          end

          alias_method :included, :registered
        end

        module InstanceMethods
          def redirect_manager
            @_redirect_manager ||= RedirectManager.new(self)
          end

          def redirect(*args, &block)
            redirect_manager.create_redirect(*args, &block)
          end
        end

        # Manages the list of proxy configurations and manipulates the sitemap
        # to include new resources based on those configurations
        class RedirectManager
          def initialize(app)
            @app = app
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

          # rubocop:disable Style/AccessorMethodName
          def get_source_file
            nil
          end
          # rubocop:enable Style/AccessorMethodName

          def template?
            true
          end

          def render(*)
            url = ::Middleman::Util.url_for(store.app, @request_path,
                                            relative: false,
                                            find_resource: true
                                           )

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

          # def request_path
          #   @request_path
          # end

          def binary?
            false
          end

          def raw_data
            {}
          end

          def ignored?
            false
          end

          def metadata
            @local_metadata.dup
          end
        end
      end
    end
  end
end
