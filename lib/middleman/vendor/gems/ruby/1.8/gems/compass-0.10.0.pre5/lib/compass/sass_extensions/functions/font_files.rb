module Compass::SassExtensions::Functions::FontFiles
  def font_files(*args)
    raise Sass::SyntaxError, "An even number of arguments must be passed to font_files()" unless args.size % 2 == 0
    files = []
    while args.size > 0
      files << "#{font_url(args.shift)} format('#{args.shift}')"
    end
    Sass::Script::String.new(files.join(", "))
  end

end
