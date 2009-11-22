module Compass::SassExtensions::Functions::Enumerate
  def enumerate(prefix, from, through, separator = "-")
    selectors = (from.value..through.value).map{|i| "#{prefix.value}#{separator}#{i}"}.join(", ")
    Sass::Script::String.new(selectors)
  end
end