require "rdoc/parser/c"

# New RDoc somehow misses class comemnts.
# copyied this function from "2.2.2" 
if ['2.4.2', '2.4.3'].include? RDoc::VERSION

  class RDoc::Parser::C
    def find_class_comment(class_name, class_meth)
      comment = nil
      if @content =~ %r{((?>/\*.*?\*/\s+))
                     (static\s+)?void\s+Init_#{class_name}\s*(?:_\(\s*)?\(\s*(?:void\s*)\)}xmi then
        comment = $1
      elsif @content =~ %r{Document-(?:class|module):\s#{class_name}\s*?(?:<\s+[:,\w]+)?\n((?>.*?\*/))}m
        comment = $1
      else
        if @content =~ /rb_define_(class|module)/m then
          class_name = class_name.split("::").last
          comments = []
          @content.split(/(\/\*.*?\*\/)\s*?\n/m).each_with_index do |chunk, index|
            comments[index] = chunk
            if chunk =~ /rb_define_(class|module).*?"(#{class_name})"/m then
              comment = comments[index-1]
              break
            end
          end
        end
      end
      class_meth.comment = mangle_comment(comment) if comment
    end
  end
end