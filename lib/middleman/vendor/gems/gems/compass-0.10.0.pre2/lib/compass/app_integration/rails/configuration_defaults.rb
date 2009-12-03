module Compass
  module AppIntegration
    module Rails
      module ConfigurationDefaults

        def project_type_without_default
          :rails
        end

        def default_images_dir
          File.join("public", "images")
        end

        def default_fonts_dir
          File.join("public", "fonts")
        end

        def default_javascripts_dir
          File.join("public", "javascripts")
        end

        def default_http_images_path
          "/images"
        end

        def default_http_javascripts_path
          "/javascripts"
        end

        def default_http_fonts_path
          "/fonts"
        end

        def default_http_stylesheets_path
          "/stylesheets"
        end

        def default_extensions_dir
          "vendor/plugins/compass/extensions"
        end

      end
    end
  end
end
