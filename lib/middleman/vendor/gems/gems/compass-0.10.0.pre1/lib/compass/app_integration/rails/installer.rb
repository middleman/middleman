module Compass
  module Installers
    class Base
    end
    class ManifestInstaller < Base
    end
  end

  module AppIntegration
    module Rails    
      class Installer < Compass::Installers::ManifestInstaller

        def completed_configuration
          config = {}
          config[:sass_dir] = prompt_sass_dir unless sass_dir_without_default
          config[:css_dir] = prompt_css_dir unless css_dir_without_default
          config unless config.empty?
        end

        def write_configuration_files(config_file = nil)
          config_file ||= targetize('config/compass.rb')
          directory File.dirname(config_file)
          write_file config_file, config_contents
          directory File.dirname(targetize('config/initializers/compass.rb'))
          write_file targetize('config/initializers/compass.rb'), initializer_contents
        end

        def config_files_exist?
          File.exists?(targetize('config/compass.config')) &&
          File.exists?(targetize('config/initializers/compass.rb'))
        end

        def prepare
          write_configuration_files unless config_files_exist?
        end

        def finalize(options = {})
          if options[:create]
            puts <<-NEXTSTEPS

  Congratulations! Your rails project has been configured to use Compass.
  Sass will automatically compile your stylesheets during the next
  page request and keep them up to date when they change.
  Make sure you restart your server!
  NEXTSTEPS
          end
          if manifest.has_stylesheet?
            puts "\nNext add these lines to the head of your layouts:\n\n"
            puts stylesheet_links
            puts "\n(You are using haml, aren't you?)"
          end
        end


        def install_location_for_html(to, options)
          separate("public/#{pattern_name_as_dir}#{to}")
        end

        def prompt_sass_dir
          recommended_location = separate('app/stylesheets')
          default_location = separate('public/stylesheets/sass')
          print %Q{Compass recommends that you keep your stylesheets in #{recommended_location}
  instead of the Sass default location of #{default_location}.
  Is this OK? (Y/n) }
          answer = gets.downcase[0]
          answer == ?n ? default_location : recommended_location
        end

        def prompt_css_dir
          recommended_location = separate("public/stylesheets/compiled")
          default_location = separate("public/stylesheets")
          puts
          print %Q{Compass recommends that you keep your compiled css in #{recommended_location}/
  instead the Sass default of #{default_location}/.
  However, if you're exclusively using Sass, then #{default_location}/ is recommended.
  Emit compiled stylesheets to #{recommended_location}/? (Y/n) }
          answer = gets.downcase[0]
          answer == ?n ? default_location : recommended_location
        end

        def config_contents
          Compass.configuration.serialize do |prop, value|
            if prop == :project_path
              "project_path = RAILS_ROOT if defined?(RAILS_ROOT)\n"
            elsif prop == :output_style
              ""
            end
          end
        end

        def initializer_contents
          %Q{require 'compass'
  # If you have any compass plugins, require them here.
  Compass.configuration.parse(File.join(RAILS_ROOT, "config", "compass.config"))
  Compass.configuration.environment = RAILS_ENV.to_sym
  Compass.configure_sass_plugin!
  }
        end

        def stylesheet_prefix
          if css_dir.length >= 19
            "#{css_dir[19..-1]}/"
          else
            nil
          end
        end

        def stylesheet_links
          html = "%head\n"
          manifest.each_stylesheet do |stylesheet|
            # Skip partials.
            next if File.basename(stylesheet.from)[0..0] == "_"
            ss_line = "  = stylesheet_link_tag '#{stylesheet_prefix}#{stylesheet.to.sub(/\.sass$/,'.css')}'"
            if stylesheet.options[:media]
              ss_line += ", :media => '#{stylesheet.options[:media]}'"
            end
            if stylesheet.options[:condition]
              ss_line = "  /[if #{stylesheet.options[:condition]}]\n  " + ss_line
            end
            html << ss_line + "\n"
          end
          html
        end
      end
    end
  end
end
