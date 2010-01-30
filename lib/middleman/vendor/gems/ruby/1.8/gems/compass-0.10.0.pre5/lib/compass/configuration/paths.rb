module Compass::Configuration::Paths

  TRAILING_SEPARATOR = %r{.(/|#{Regexp.escape(File::SEPARATOR)})$}

  def strip_trailing_separator(*attributes)
    attributes.each do |attr|
      alias_method "#{attr}_with_trailing_separator".to_sym, attr
      class_eval %Q{
        def #{attr}                                # def css_dir
          path = #{attr}_with_trailing_separator   #   path = css_dir_with_trailing_separator
          if path =~ TRAILING_SEPARATOR            #   if path =~ TRAILING_SEPARATOR
            path = path[0..-($1.length+1)]         #     path = path[0..-($1.length+1)]
          end                                      #   end
          path                                     #   path
        end                                        # end
      }
    end
  end
end
