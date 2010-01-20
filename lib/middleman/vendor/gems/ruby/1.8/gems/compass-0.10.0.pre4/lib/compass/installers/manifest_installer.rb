module Compass
  module Installers

    class ManifestInstaller < Base

      attr_accessor :manifest

      def initialize(template_path, target_path, options = {})
        super
        @manifest = Manifest.new(manifest_file, options) if template_path
      end

      def manifest_file
        @manifest_file ||= File.join(template_path, "manifest.rb")
      end

      # Initializes the project to work with compass
      def init
        dirs = manifest.map do |entry|
          loc = send("install_location_for_#{entry.type}", entry.to, entry.options)
          File.dirname(loc)
        end

        if manifest.has_stylesheet?
          dirs << sass_dir
          dirs << css_dir
        end

        dirs.uniq.sort.each do |dir|
          directory targetize(dir)
        end
      end

      # The default install method. Calls install_<type> methods in the order specified by the manifest.
      def install
        manifest.each do |entry|
          send("install_#{entry.type}", entry.from, entry.to, entry.options)
        end
      end

      def stylesheet_links
        html = "<head>\n"
        manifest.each_stylesheet do |stylesheet|
          # Skip partials.
          next if File.basename(stylesheet.from)[0..0] == "_"
          media = if stylesheet.options[:media]
            %Q{ media="#{stylesheet.options[:media]}"}
          end
          ss_line = %Q{  <link href="#{http_stylesheets_path}/#{stylesheet.to.sub(/\.sass$/,'.css')}"#{media} rel="stylesheet" type="text/css" />}
          if stylesheet.options[:condition]
            ss_line = "  <!--[if #{stylesheet.options[:condition]}]>\n    #{ss_line}\n  <![endif]-->"
          end
          html << ss_line + "\n"
        end
        html << "</head>"
      end
    end
  end
end
