module Sprockets
  class Preprocessor
    attr_reader :environment, :concatenation, :source_files, :asset_paths
    
    def initialize(environment, options = {})
      @environment = environment
      @concatenation = Concatenation.new
      @source_files = []
      @asset_paths = []
      @options = options
    end
    
    def require(source_file)
      return if source_files.include?(source_file)
      source_files << source_file
      
      source_file.each_source_line do |source_line|
        if source_line.require?
          require_from_source_line(source_line)
        elsif source_line.provide?
          provide_from_source_line(source_line)
        else
          record_source_line(source_line)
        end
      end
    end
    
    def provide(asset_path)
      return if !asset_path || asset_paths.include?(asset_path)
      asset_paths << asset_path
    end
    
    protected
      attr_reader :options
    
      def require_from_source_line(source_line)
        require pathname_from(source_line).source_file
      end
      
      def provide_from_source_line(source_line)
        provide asset_path_from(source_line)
      end
      
      def record_source_line(source_line)
        unless source_line.comment? && strip_comments?
          concatenation.record(source_line)
        end
      end

      def strip_comments?
        options[:strip_comments] != false
      end
      
      def pathname_from(source_line)
        pathname = send(pathname_finder_from(source_line), source_line)
        raise_load_error_for(source_line) unless pathname
        pathname
      end

      def pathname_for_require_from(source_line)
        environment.find(location_from(source_line))
      end
      
      def pathname_for_relative_require_from(source_line)
        source_line.source_file.find(location_from(source_line))
      end

      def pathname_finder_from(source_line)
        "pathname_for_#{kind_of_require_from(source_line)}_from"
      end

      def kind_of_require_from(source_line)
        source_line.require[/^(.)/, 1] == '"' ? :relative_require : :require
      end

      def location_from(source_line)
        location = source_line.require[/^.(.*).$/, 1]
        File.join(File.dirname(location), File.basename(location, ".js") + ".js")
      end
      
      def asset_path_from(source_line)
        source_line.source_file.find(source_line.provide, :directory)
      end

      def raise_load_error_for(source_line)
        kind = kind_of_require_from(source_line).to_s.tr("_", " ")
        file = File.split(location_from(source_line)).last
        raise LoadError, "can't find file for #{kind} `#{file}' (#{source_line.inspect})"
      end
  end
end
