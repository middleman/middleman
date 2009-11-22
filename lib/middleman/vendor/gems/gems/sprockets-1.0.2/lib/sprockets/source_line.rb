module Sprockets
  class SourceLine
    attr_reader :source_file, :line, :number

    def initialize(source_file, line, number)
      @source_file = source_file
      @line = line
      @number = number
    end

    def comment
      @comment ||= line[/^\s*\/\/(.*)/, 1]
    end

    def comment?
      !!comment
    end

    def comment!
      @comment = line
    end

    def begins_multiline_comment?
      line =~ /^\s*\/\*(.*)/
    end

    def begins_pdoc_comment?
      line =~ /^\s*\/\*\*(.*)/
    end

    def ends_multiline_comment?
      line =~ /^(.*)\*\/\s*/
    end

    def ends_pdoc_comment?
      line =~ /^(.*)\*\*\/\s*/
    end

    def require
      @require ||= (comment || "")[/^=\s+require\s+(\"(.*?)\"|<(.*?)>)\s*$/, 1]
    end
    
    def require?
      !!require
    end
    
    def provide
      @provide ||= (comment || "")[/^=\s+provide\s+\"(.*?)\"\s*$/, 1]
    end
    
    def provide?
      !!provide
    end
    
    def inspect
      "line #@number of #{@source_file.pathname}"
    end
    
    def to_s(constants = source_file.environment.constants)
      result = line.chomp
      interpolate_constants!(result, constants)
      strip_trailing_whitespace!(result)
      result + $/
    end
    
    protected
      def interpolate_constants!(result, constants)
        result.gsub!(/<%=(.*?)%>/) do
          constant = $1.strip
          if value = constants[constant]
            value
          else
            raise UndefinedConstantError, "couldn't find constant `#{constant}' in #{inspect}"
          end
        end
      end
      
      def strip_trailing_whitespace!(result)
        result.gsub!(/\s+$/, "")
      end
  end
end
