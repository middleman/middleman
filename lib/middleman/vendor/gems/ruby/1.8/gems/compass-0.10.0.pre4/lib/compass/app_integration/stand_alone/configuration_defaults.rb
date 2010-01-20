module Compass
  module AppIntegration
    module StandAlone
      module ConfigurationDefaults
        def default_project_type
          :stand_alone
        end

        def sass_dir_without_default
          "src"
        end

        def javascripts_dir_without_default
          "javascripts"
        end

        def css_dir_without_default
          "stylesheets"
        end

        def images_dir_without_default
          "images"
        end

        def default_cache_dir
          ".sass-cache"
        end
      end

    end
  end
end
