module Sprockets
  class Concatenation
    attr_reader :source_lines
    
    def initialize
      @source_lines = []
      @source_file_mtimes = {}
    end
    
    def record(source_line)
      source_lines << source_line
      record_mtime_for(source_line.source_file)
      source_line
    end
    
    def to_s
      source_lines.join
    end

    def mtime
      @source_file_mtimes.values.max
    end
    
    def save_to(filename)
      timestamp = mtime
      File.open(filename, "w") { |file| file.write(to_s) }
      File.utime(timestamp, timestamp, filename)
      true
    end

    protected
      def record_mtime_for(source_file)
        @source_file_mtimes[source_file] ||= source_file.mtime
      end
  end
end
