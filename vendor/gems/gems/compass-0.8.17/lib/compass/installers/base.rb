module Compass
  module Installers

    class Base

      include Actions

      attr_accessor :template_path, :target_path, :working_path
      attr_accessor :options
      attr_accessor :manifest

      def initialize(template_path, target_path, options = {})
        @template_path = template_path
        @target_path = target_path
        @working_path = Dir.getwd
        @options = options
        @manifest = Manifest.new(manifest_file) if template_path
        self.logger = options[:logger]
      end

      def manifest_file
        @manifest_file ||= File.join(template_path, "manifest.rb")
      end

      [:css_dir, :sass_dir, :images_dir, :javascripts_dir].each do |dir|
        define_method dir do
          Compass.configuration.send(dir)
        end
      end

      # Initializes the project to work with compass
      def init
        dirs = manifest.map do |entry|
          File.dirname(send("install_location_for_#{entry.type}", entry.to, entry.options))
        end

        if manifest.has_stylesheet?
          dirs << sass_dir
          dirs << css_dir
        end

        dirs.uniq.sort.each do |dir|
          directory targetize(dir)
        end
      end

      # Runs the installer.
      # Every installer must conform to the installation strategy of prepare, install, and then finalize.
      # A default implementation is provided for each step.
      def run(options = {})
        prepare
        install
        finalize unless options[:skip_finalization]
      end

      # The default prepare method -- it is a no-op.
      # Generally you would create required directories, etc.
      def prepare
      end

      def configure_option_with_default(opt)
        value = options[opt]
        value ||= begin
          default_method = "default_#{opt}".to_sym
          send(default_method) if respond_to?(default_method)
        end
        send("#{opt}=", value)
      end

      # The default install method. Calls install_<type> methods in the order specified by the manifest.
      def install
        manifest.each do |entry|
          send("install_#{entry.type}", entry.from, entry.to, entry.options)
        end
      end

      # The default finalize method -- it is a no-op.
      # This could print out a message or something.
      def finalize
      end

      def compilation_required?
        false
      end

      def pattern_name_as_dir
        "#{options[:pattern_name]}/" if options[:pattern_name]
      end

      def self.installer(type, installer_opts = {}, &locator)
        locator ||= lambda{|to| to}
        loc_method = "install_location_for_#{type}".to_sym
        define_method("simple_#{loc_method}", locator)
        define_method(loc_method) do |to, options|
          if options[:like] && options[:like] != type
            send("install_location_for_#{options[:like]}", to, options)
          else
            send("simple_#{loc_method}", to)
          end
        end
        define_method "install_#{type}" do |from, to, options|
          from = templatize(from)
          to = targetize(send(loc_method, to, options))
          copy from, to, nil, (installer_opts[:binary] || options[:binary])
        end
      end

      installer :stylesheet do |to|
        "#{sass_dir}/#{pattern_name_as_dir}#{to}"
      end

      installer :css do |to|
        "#{css_dir}/#{to}"
      end

      installer :image, :binary => true do |to|
        "#{images_dir}/#{to}"
      end

      installer :javascript do |to|
        "#{javascripts_dir}/#{to}"
      end

      installer :file do |to|
        "#{pattern_name_as_dir}#{to}"
      end

      # returns an absolute path given a path relative to the current installation target.
      # Paths can use unix style "/" and will be corrected for the current platform.
      def targetize(path)
        strip_trailing_separator File.join(target_path, separate(path))
      end

      # returns an absolute path given a path relative to the current template.
      # Paths can use unix style "/" and will be corrected for the current platform.
      def templatize(path)
        strip_trailing_separator File.join(template_path, separate(path))
      end

      def stylesheet_links
        html = "<head>\n"
        manifest.each_stylesheet do |stylesheet|
          # Skip partials.
          next if File.basename(stylesheet.from)[0..0] == "_"
          media = if stylesheet.options[:media]
            %Q{ media="#{stylesheet.options[:media]}"}
          end
          ss_line = %Q{  <link href="/stylesheets/#{stylesheet.to.sub(/\.sass$/,'.css')}"#{media} rel="stylesheet" type="text/css" />}
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
