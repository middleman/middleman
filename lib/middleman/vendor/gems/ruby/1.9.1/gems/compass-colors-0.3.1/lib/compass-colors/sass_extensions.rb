require 'sass'

module Sass::Script::Functions
  module Colors
    extend self
    def rgb_value(color)
      if color.respond_to?(:rgb)
        color.rgb
      else
        color.value
      end
    end
  end
  # Takes a color object and amount by which to lighten it (0 to 100).
  def lighten(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.l += amount.value / 100.0
    hsl.to_color
  end

  # Takes a color object and percent by which to lighten it (0 to 100).
  def lighten_percent(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.l += (1 - hsl.l) * (amount.value / 100.0)
    hsl.to_color
  end

  # Takes a color object and amount by which to darken it (0 to 100).
  def darken(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.l -= amount.value / 100.0
    hsl.to_color
  end

  # Takes a color object and percent by which to darken it (0 to 100).
  def darken_percent(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.l *= 1.0 - (amount.value / 100.0)
    hsl.to_color
  end

  # Saturate (make a color "richer") a color by the given amount (0 to 100)
  def saturate(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.s += amount.value / 100.0
    hsl.to_color
  end

  # Saturate (make a color "richer") a color by the given percent (0 to 100)
  def saturate_percent(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.s += (1 - hsl.s) * (amount.value / 100.0)
    hsl.to_color
  end

  # Desaturate (make a color "grayer") a color by the given amount (0 to 100)
  def desaturate(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.s -= amount.value / 100.0
    hsl.to_color
  end

  # Desaturate (make a color "grayer") a color by the given percent (0 to 100)
  def desaturate_percent(color, amount)
    hsl = Compass::Colors::HSL.from_color(color)
    hsl.s *= (1.0 - (amount.value / 100.0))
    hsl.to_color
  end

  # Return the hue of a color as a number between 0 and 360
  def hue(color)
    Sass::Script::Number.new(Compass::Colors::HSL.from_color(color).h.round)
  end

  # Return the saturation of a color as a number between 0 and 100
  def saturation(color)
    Sass::Script::Number.new((Compass::Colors::HSL.from_color(color).s * 100).round)
  end

  # Return the luminosity of a color as a number between 0 and 100
  def luminosity(color)
    Sass::Script::Number.new((Compass::Colors::HSL.from_color(color).l * 100).round)
  end
  alias lightness luminosity

  # Mixes two colors by some amount (0 to 100). Defaults to 50.
  def mix(color1, color2, amount = nil)
    percent = amount ? amount.value.round / 100.0 : 0.5
    new_colors = Colors.rgb_value(color1).zip(Colors.rgb_value(color2)).map{|c1, c2| (c1 * percent) + (c2 * (1 - percent))}
    Sass::Script::Color.new(new_colors)
  end

  # Returns the grayscale equivalent color for the given color
  def grayscale(color)
    hsl = Compass::Colors::HSL.from_color(color)
    g = (hsl.l * 255).round
    Sass::Script::Color.new([g, g, g])
  end

  # adjust the hue of a color by the given number of degrees.
  def adjust_hue(color, degrees)
    hsl = Compass::Colors::HSL.from_color(color)
    degrees = degrees.value.to_f.round if degrees.is_a?(Sass::Script::Literal)
    hsl.h += degrees
    hsl.to_color
  end

  def complement(color)
    adjust_hue color, 180
  end

end
