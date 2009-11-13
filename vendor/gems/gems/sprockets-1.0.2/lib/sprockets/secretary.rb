module Sprockets
  class Secretary
    DEFAULT_OPTIONS = {
      :root         => ".",
      :load_path    => [],
      :source_files => [],
      :expand_paths => true
    }

    attr_reader :environment, :preprocessor
    
    def initialize(options = {})
      reset!(options)
    end

    def reset!(options = @options)
      @options = DEFAULT_OPTIONS.merge(options)
      @environment  = Sprockets::Environment.new(@options[:root])
      @preprocessor = Sprockets::Preprocessor.new(@environment)

      add_load_locations(@options[:load_path])
      add_source_files(@options[:source_files])
    end

    def add_load_location(load_location, options = {})
      add_load_locations([load_location], options)
    end

    def add_load_locations(load_locations, options = {})
      expand_paths(load_locations, options).each do |load_location|
        environment.register_load_location(load_location)
      end
    end
    
    def add_source_file(source_file, options = {})
      add_source_files([source_file], options)
    end
    
    def add_source_files(source_files, options = {})
      expand_paths(source_files, options).each do |source_file|
        if pathname = environment.find(source_file)
          preprocessor.require(pathname.source_file)
        else
          raise Sprockets::LoadError, "no such file `#{source_file}'"
        end
      end
    end
    
    def concatenation
      preprocessor.concatenation
    end
    
    def install_assets
      if @options[:asset_root]
        preprocessor.asset_paths.each do |asset_path|
          copy_assets_from(asset_path.absolute_location)
        end
      end
    end
    
    def source_last_modified
      preprocessor.source_files.map { |s| s.mtime }.max
    end
    
    protected
      def expand_paths(paths, options = {})
        if options.has_key?(:expand_paths) ? options[:expand_paths] : @options[:expand_paths]
          paths.map { |path| Dir[from_root(path)].sort }.flatten.compact
        else
          paths.map { |path| from_root(path) }
        end
      end
      
      def from_root(path)
        if Sprockets.absolute?(path)
          path
        else
          File.join(@options[:root], path)
        end
      end
      
      def copy_assets_from(asset_path)
        relative_file_paths_beneath(asset_path).each do |filename|
          source, destination = File.join(asset_path, filename), File.join(asset_root, File.dirname(filename))
          if !File.directory?(source)
            FileUtils.mkdir_p(destination)
            FileUtils.cp(source, destination)
          end
        end
      end
      
      def relative_file_paths_beneath(path)
        Dir[File.join(path, "**", "*")].map do |filename|
          File.join(*path_pieces(filename)[path_pieces(path).length..-1])
        end
      end
      
      def asset_root
        from_root(@options[:asset_root])
      end
      
      def path_pieces(path)
        path.split(File::SEPARATOR)
      end
  end
end
