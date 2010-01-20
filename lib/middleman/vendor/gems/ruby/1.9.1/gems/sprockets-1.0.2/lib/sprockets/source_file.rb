module Sprockets
  class SourceFile
    attr_reader :environment, :pathname

    def initialize(environment, pathname)
      @environment = environment
      @pathname = pathname
    end

    def source_lines
      @lines ||= begin
        lines = []

        comments = []
        File.open(pathname.absolute_location) do |file|
          file.each do |line|
            lines << line = SourceLine.new(self, line, file.lineno)

            if line.begins_pdoc_comment? || comments.any?
              comments << line
            end

            if line.ends_multiline_comment?
              if line.ends_pdoc_comment?
                comments.each { |l| l.comment! }
              end
              comments.clear
            end
          end
        end

        lines
      end
    end

    def each_source_line(&block)
      source_lines.each(&block)
    end

    def find(location, kind = :file)
      pathname.parent_pathname.find(location, kind)
    end
    
    def ==(source_file)
      pathname == source_file.pathname
    end
    
    def mtime
      File.mtime(pathname.absolute_location)
    rescue Errno::ENOENT
      Time.now
    end
  end
end
