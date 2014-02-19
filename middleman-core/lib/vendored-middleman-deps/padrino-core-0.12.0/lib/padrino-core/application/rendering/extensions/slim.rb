begin
  require 'slim'

  if defined? Padrino::Rendering
    Padrino::Rendering.engine_configurations[:slim] = {
      :generator => Temple::Generators::RailsOutputBuffer,
      :buffer => "@_out_buf",
      :use_html_safe => true,
      :disable_capture => true,
    }

    class Slim::Template
      include Padrino::Rendering::SafeTemplate

      def precompiled_preamble(locals)
        "__in_slim_template = true\n" << super
      end
    end
  end
rescue LoadError
end
