module Compass
  module Installers

    class Base

      include Actions

      attr_accessor :template_path, :target_path, :working_path
      attr_accessor :options

      def initialize(template_path, target_path, options = {})
        @template_path = template_path
        @target_path = target_path
        @working_path = Dir.getwd
        @options = options
        self.logger = options[:logger]
      end

      [:css_dir, :sass_dir, :images_dir, :javascripts_dir, :http_stylesheets_path, :fonts_dir].each do |dir|
        define_method dir do
          Compass.configuration.send(dir)
        end
        define_method "#{dir}_without_default" do
          Compass.configuration.send("#{dir}_without_default")
        end
      end

      # Runs the installer.
      # Every installer must conform to the installation strategy of prepare, install, and then finalize.
      # A default implementation is provided for each step.
      def run(options = {})
        prepare
        install
        finalize(options) unless options[:skip_finalization]
      end

      # The default prepare method -- it is a no-op.
      # Generally you would create required directories, etc.
      def prepare
      end

      # The install method override this to install
      def install
        raise "Not Yet Implemented"
      end

      # The default finalize method -- it is a no-op.
      # This could print out a message or something.
      def finalize(options = {})
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

      installer :font do |to|
        "#{fonts_dir}/#{to}"
      end

      installer :file do |to|
        "#{pattern_name_as_dir}#{to}"
      end

      installer :html do |to|
        "#{pattern_name_as_dir}#{to}"
      end

      alias install_html_without_haml install_html
      def install_html(from, to, options)
        if to =~ /\.haml$/
          require 'haml'
          to = to[0..-(".haml".length+1)]
          if respond_to?(:install_location_for_html)
            to = install_location_for_html(to, options)
          end
          contents = File.read(templatize(from))
          if options.delete(:erb)
            ctx = TemplateContext.ctx(:to => to, :options => options)
            contents = process_erb(contents, ctx)
          end
          Compass.configure_sass_plugin!
          html = Haml::Engine.new(contents, :filename => templatize(from)).render
          write_file(targetize(to), html, options)
        else
          install_html_without_haml(from, to, options)
        end
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

      # Emits an HTML fragment that can be used to link to the compiled css files
      def stylesheet_links
        ""
      end
    end
  end
end
require 'compass/installers/bare_installer'
require 'compass/installers/manifest_installer'
