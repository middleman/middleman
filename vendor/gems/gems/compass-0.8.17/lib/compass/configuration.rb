require 'singleton'

module Compass
  class Configuration
    include Singleton

    ATTRIBUTES = [
      :project_type,
      :project_path,
      :http_path,
      :css_dir,
      :sass_dir,
      :images_dir,
      :javascripts_dir,
      :output_style,
      :environment,
      :relative_assets,
      :http_images_path,
      :http_stylesheets_path,
      :http_javascripts_path,
      :additional_import_paths,
      :sass_options
    ]

    attr_accessor *ATTRIBUTES

    attr_accessor :required_libraries

    def initialize
      self.required_libraries = []
    end

    # parses a manifest file which is a ruby script
    # evaluated in a Manifest instance context
    def parse(config_file)
      open(config_file) do |f|
        parse_string(f.read, config_file)
      end
    end

    def parse_string(contents, filename)
      bind = binding
      eval(contents, bind, filename)
      ATTRIBUTES.each do |prop|
        value = eval(prop.to_s, bind) rescue nil
        self.send("#{prop}=", value) if value
      end
      if @added_import_paths
        self.additional_import_paths ||= []
        self.additional_import_paths += @added_import_paths
      end
      issue_deprecation_warnings
    end

    def set_all(options)
      ATTRIBUTES.each do |a|
        self.send("#{a}=", options[a]) if options.has_key?(a)
      end
    end

    def set_maybe(options)
      ATTRIBUTES.each do |a|
        self.send("#{a}=", options[a]) if options[a]
      end
    end

    def default_all(options)
      ATTRIBUTES.each do |a|
        set_default_unless_set(a, options[a])
      end
    end

    def set_default_unless_set(attribute, value)
      self.send("#{attribute}=", value) unless self.send(attribute)
    end

    def set_defaults!
      ATTRIBUTES.each do |a|
        set_default_unless_set(a, default_for(a))
      end
    end

    def default_for(attribute)
      method = "default_#{attribute}".to_sym
      self.send(method) if respond_to?(method)
    end

    def default_sass_dir
      "src"
    end

    def default_css_dir
      "stylesheets"
    end

    def default_images_dir
      "images"
    end

    def default_http_path
      "/"
    end

    def comment_for_http_path
      "# Set this to the root of your project when deployed:\n"
    end

    def relative_assets?
      # the http_images_path is deprecated, but here for backwards compatibility.
      relative_assets || http_images_path == :relative
    end

    def comment_for_relative_assets
      unless relative_assets
        %q{# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
}
      else
        ""
      end
    end

    def default_output_style
      if environment == :development
        :expanded
      else
        :compact
      end
    end

    def default_line_comments
      environment == :development
    end

    def sass_path
      if project_path && sass_dir
        File.join(project_path, sass_dir)
      end
    end

    def css_path
      if project_path && css_dir
        File.join(project_path, css_dir)
      end
    end

    def root_relative(path)
      hp = http_path || default_http_path
      hp = hp[0..-2] if hp[-1..-1] == "/"
      "#{hp}/#{path}"
    end

    def add_import_path(*paths)
      # The @added_import_paths variable works around an issue where
      # the additional_import_paths gets overwritten during parse
      @added_import_paths ||= []
      @added_import_paths += paths
      self.additional_import_paths ||= []
      self.additional_import_paths += paths
    end

    # When called with a block, defines the asset host url to be used.
    # The block must return a string that starts with a protocol (E.g. http).
    # The block will be passed the root-relative url of the asset.
    # When called without a block, returns the block that was previously set.
    def asset_host(&block)
      if block_given?
        @asset_host = block
      else
        @asset_host
      end
    end

    # When called with a block, defines the cache buster strategy to be used.
    # The block must return nil or a string that can be appended to a url as a query parameter.
    # The returned string must not include the starting '?'.
    # The block will be passed the root-relative url of the asset.
    # If the block accepts two arguments, it will also be passed a File object
    # that points to the asset on disk -- which may or may not exist.
    # When called without a block, returns the block that was previously set.
    def asset_cache_buster(&block)
      if block_given?
        @asset_cache_buster = block
      else
        @asset_cache_buster
      end
    end


    def serialize
      if asset_cache_buster
        raise Compass::Error, "Cannot serialize a configuration with asset_cache_buster set."
      end
      if asset_host
        raise Compass::Error, "Cannot serialize a configuration with asset_host set."
      end
      contents = ""
      required_libraries.each do |lib|
        contents << %Q{require '#{lib}'\n}
      end
      contents << "# Require any additional compass plugins here.\n"
      contents << "\n" if required_libraries.any?
      ATTRIBUTES.each do |prop|
        value = send(prop)
        if respond_to?("comment_for_#{prop}")
          contents << send("comment_for_#{prop}")
        end
        if block_given? && (to_emit = yield(prop, value))
          contents << to_emit
        else
          contents << Configuration.serialize_property(prop, value) unless value.nil?
        end
      end
      contents
    end

    def self.serialize_property(prop, value)
      %Q(#{prop} = #{value.inspect}\n)
    end

    def to_compiler_arguments(additional_options)
      [project_path, sass_path, css_path, to_sass_engine_options.merge(additional_options)]
    end

    def to_sass_plugin_options
      locations = {}
      locations[sass_path] = css_path if sass_path && css_path
      Compass::Frameworks::ALL.each do |framework|
        locations[framework.stylesheets_directory] = css_path || css_dir || "."
      end
      resolve_additional_import_paths.each do |additional_path|
        locations[additional_path] = File.join(css_path || css_dir || ".", File.basename(additional_path))
      end
      plugin_opts = {:template_location => locations}
      plugin_opts[:style] = output_style if output_style
      plugin_opts[:line_comments] = default_line_comments if environment
      plugin_opts.merge!(sass_options || {})
      plugin_opts
    end

    def resolve_additional_import_paths
      (additional_import_paths || []).map do |path|
        if project_path && !absolute_path?(path)
          File.join(project_path, path)
        else
          path
        end
      end
    end

    def to_sass_engine_options
      engine_opts = {:load_paths => sass_load_paths}
      engine_opts[:style] = output_style if output_style
      engine_opts[:line_comments] = default_line_comments if environment
      engine_opts.merge!(sass_options || {})
    end

    def sass_load_paths
      load_paths = []
      load_paths << sass_path if sass_path
      Compass::Frameworks::ALL.each do |framework|
        load_paths << framework.stylesheets_directory if File.exists?(framework.stylesheets_directory)
      end
      load_paths += resolve_additional_import_paths
      load_paths
    end

    # Support for testing.
    def reset!
      ATTRIBUTES.each do |attr|
        send("#{attr}=", nil)
      end
      @asset_cache_buster = nil
      @asset_host = nil
      @added_import_paths = nil
      self.required_libraries = []
    end

    def issue_deprecation_warnings
      if http_images_path == :relative
        puts "DEPRECATION WARNING: Please set relative_assets = true to enable relative paths."
      end
    end

    def require(lib)
      required_libraries << lib
      super
    end

    def absolute_path?(path)
      # This is only going to work on unix, gonna need a better implementation.
      path.index(File::SEPARATOR) == 0
    end
  end

  module ConfigHelpers
    def configuration
      if block_given?
        yield Configuration.instance
      end
      Configuration.instance
    end

    def sass_plugin_configuration
      configuration.to_sass_plugin_options
    end

    def configure_sass_plugin!
      @sass_plugin_configured = true
      Sass::Plugin.options.merge!(sass_plugin_configuration)
    end

    def sass_plugin_configured?
      @sass_plugin_configured
    end

    def sass_engine_options
      configuration.to_sass_engine_options
    end
  end

  extend ConfigHelpers

end
