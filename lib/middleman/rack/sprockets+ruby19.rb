module Sprockets
  class SourceFile
    def source_lines
      @lines ||= begin
        lines = []

        comments = []
        File.open(pathname.absolute_location, 'rb') do |file|
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
  end
end