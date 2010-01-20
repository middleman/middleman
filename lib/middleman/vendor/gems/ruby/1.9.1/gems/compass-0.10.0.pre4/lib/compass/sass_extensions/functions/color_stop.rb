module Compass::SassExtensions::Functions::ColorStop
  def color_stop(*args)
    raise Sass::SyntaxError, "An even number of arguments must be passed to color-stop()" unless args.size % 2 == 0
    stops = []
    while args.size > 0
      stops << "color-stop(#{args.shift}, #{args.shift})"
    end
    Sass::Script::String.new(stops.join(", "))
  end
end
