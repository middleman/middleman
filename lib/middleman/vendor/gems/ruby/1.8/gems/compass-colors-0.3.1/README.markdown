Compass Colors
==============

This compass extension provides support for working with colors in Sass and generating color themes for use on your website.

Installing
==========

    sudo gem install chriseppstein-compass-colors


To install a theme into your existing compass project, add the following to your compass configuration file:

    require 'compass-colors'

Then run this command:

    compass -f colors -p <Theme Name>

The _theme.sass partial can then be imported into your stylesheets and the color constants can be used.

    @import theme.sass    
    
Supported Color Themes
======================

With all of these themes, you must pick a base color and the theme takes it from there:

* Basic/Monochromatic (basic)
* Complementary (complementary)
* Triadic (triadic)
* Split Complementary (split_complement)
* Analogous (analogous)

Sass Functions Provided
=======================

* `lighten(color, percentage)` - Create a color lighter by the percent amount provided.
* `darken(color, percentage)`  - Create a color darker by the percent amount provided.
* `saturate(color, percentage)` - Increase the saturation of a color by the percent amount provided.
* `desaturate(color, percentage)` - Decrease the saturation of a color by the percent amount provided.
* `hue(color)` - Extract the hue from the color in degrees (0-360). Suitable to be passed as the first argument of hsl.
* `saturation(color)` - Extract the saturation from the color in percent (0-100). Suitable to be passed as the second argument of hsl.
* `luminosity(color)` - Extract the luminosity from the color in percent (0-100). Suitable to be passed as the third argument of hsl.
* `mix(color1, color2, percentage)` - Create a new color by mixing two colors together. Percentage (0-100) is optional, and indicates how
  much of color2 should be mixed into color1.
* `grayscale(color)` - Create a gray color by mapping the color provided to the grayscale.
* `adjust_hue(color, degrees)` - Add the number of degrees provided to the hue of the color keeping luminosity and saturation constant.
  Degrees can be negative.
* `complement(color)` - Returns the compliment of the color provided.
