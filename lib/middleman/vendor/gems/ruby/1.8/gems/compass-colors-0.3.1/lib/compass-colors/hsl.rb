module Compass
  module Colors
    class HSL

      # Stored in degrees [0, 360)
      attr_reader :h
      # Stored as a number from [0,1]
      attr_reader :s, :l

      def self.from_color(color)
        rgb = color.respond_to?(:rgb) ? color.rgb : color.value
        from_rgb(*rgb)
      end

      def self.from_rgb(r, g, b)
        rgb = [r,g,b]
        rgb.map!{|c| c / 255.0}
        min_rgb = rgb.min
        max_rgb = rgb.max
        delta = max_rgb - min_rgb

        lightness = (max_rgb + min_rgb) / 2.0

        if delta < 1e-5
           hue = 0
           saturation = 0
        else
           saturation = if ( lightness < 0.5 )
              delta / ( max_rgb + min_rgb )
           else
             delta / ( 2 - max_rgb - min_rgb )
           end

           deltas = rgb.map{|c| (((max_rgb - c) / 6.0) + (delta / 2.0)) / delta}

           hue = if (rgb[0] - max_rgb).abs < 1e-5
             deltas[2] - deltas[1]
           elsif (rgb[1] - max_rgb).abs < 1e-5
             ( 1.0 / 3.0 ) + deltas[0] - deltas[2]
           else
             ( 2.0 / 3.0 ) + deltas[1] - deltas[0]
           end
           hue += 1 if hue < 0
           hue -= 1 if hue > 1
         end
         from_fractions(hue, saturation, lightness)
      end

      def self.from_fractions(hue, saturation, lightness)
        HSL.new(360 * hue, saturation, lightness)
      end

      def initialize(h, s, l)
        self.h = h
        self.s = s
        self.l = l
      end

      def to_color
        m2 = l <= 0.5 ? l * (s + 1) : l + s - l * s
        m1 = l * 2 - m2
        Sass::Script::Color.new([hue_to_rgb(m1, m2, hp + 1.0/3),
                                 hue_to_rgb(m1, m2, hp),
                                 hue_to_rgb(m1, m2, hp - 1.0/3)].map { |c| (c * 0xff).round })
      end

      def h=(hue)
        @h = hue % 360
      end

      def s=(saturation)
        @s = if saturation < 0
          0.0
        elsif saturation > 1
          1.0
        else
          saturation
        end
      end

      def l=(lightness)
        @l = if lightness < 0
          0.0
        elsif lightness > 1
          1.0
        else
          lightness
        end
      end

      private
      #hue as a percentage
      def hp
        h / 360.0
      end
      # helper for making rgb
      def hue_to_rgb(m1, m2, h)
        h += 1 if h < 0
        h -= 1 if h > 1
        return m1 + (m2 - m1) * h * 6 if h * 6 < 1
        return m2 if h * 2 < 1
        return m1 + (m2 - m1) * (2.0/3 - h) * 6 if h * 3 < 2
        return m1
      end

    end
  end
end

