module Compass::SassExtensions::Functions::Selectors
  COMMA_SEPARATOR = /\s*,\s*/

  # Permute multiple selectors each of which may be comma delimited, the end result is
  # a new selector that is the equivalent of nesting each under the previous selector.
  # To illustrate, the following mixins are equivalent:
  # =mixin-a(!selector1, !selector2, !selector3)
  #   #{!selector1}
  #     #{selector2}
  #       #{selector3}
  #         width: 2px
  # =mixin-b(!selector1, !selector2)
  #   #{nest(!selector, !selector2, !selector3)}
  #     width: 2px
  def nest(*arguments)
    nested = arguments.map{|a| a.value}.inject do |memo,arg|
      ancestors = memo.split(COMMA_SEPARATOR)
      descendants = arg.split(COMMA_SEPARATOR)
      ancestors.map{|a| descendants.map{|d| "#{a} #{d}"}.join(", ")}.join(", ")
    end
    Sass::Script::String.new(nested)
  end

  # Permute two selectors, the first may be comma delimited.
  # The end result is a new selector that is the equivalent of nesting the second
  # selector under the first one in a sass file and preceding it with an &.
  # To illustrate, the following mixins are equivalent:
  # =mixin-a(!selector, !to_append)
  #   #{!selector}
  #     &#{!to_append}
  #       width: 2px
  # =mixin-b(!selector, !to_append)
  #   #{append_selector(!selector, !to_append)}
  #     width: 2px
  def append_selector(selector, to_append)
    Sass::Script::String.new(selector.value.split(COMMA_SEPARATOR).map{|s| "#{s}#{to_append}"}.join(", "))
  end

end