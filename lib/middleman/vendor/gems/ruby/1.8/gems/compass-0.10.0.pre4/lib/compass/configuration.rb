module Compass
  module Configuration

    def self.attributes_for_directory(dir_name, http_dir_name = dir_name)
      [
        "#{dir_name}_dir",
        "#{dir_name}_path",
        ("http_#{http_dir_name}_dir" if http_dir_name),
        ("http_#{http_dir_name}_path" if http_dir_name)
      ].compact.map{|a| a.to_sym}
    end

    ATTRIBUTES = [
      # What kind of project?
      :project_type,
      # Where is the project?
      :project_path,
      :http_path,
      # Where are the various bits of the project
      attributes_for_directory(:css, :stylesheets),
      attributes_for_directory(:sass, nil),
      attributes_for_directory(:images),
      attributes_for_directory(:javascripts),
      attributes_for_directory(:fonts),
      attributes_for_directory(:extensions, nil),
      # Compilation options
      :output_style,
      :environment,
      :relative_assets,
      :additional_import_paths,
      :sass_options,
      attributes_for_directory(:cache, nil),
      :cache,
      # Helper configuration
      :asset_host,
      :asset_cache_buster,
      :line_comments,
      :color_output
    ].flatten

  end
end

['adapters', 'comments', 'defaults', 'helpers', 'inheritance', 'serialization', 'data'].each do |lib|
  require "compass/configuration/#{lib}"
end
