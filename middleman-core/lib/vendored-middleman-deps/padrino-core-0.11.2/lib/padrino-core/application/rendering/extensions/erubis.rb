begin
  require 'erubis'

  module Padrino
    module Erubis
      ##
      # SafeBufferEnhancer is an Erubis Enhancer that compiles templates that
      # are fit for using ActiveSupport::SafeBuffer as a Buffer.
      #
      # @api private
      module SafeBufferEnhancer
        def add_expr_literal(src, code)
          src << " #{@bufvar}.concat((" << code << ').to_s);'
        end

        def add_expr_escaped(src, code)          
          src << " #{@bufvar}.safe_concat " << code << ';'
        end

        def add_text(src, text)
          src << " #{@bufvar}.safe_concat '" << escape_text(text) << "';" unless text.empty?
        end
      end

      ##
      # SafeBufferTemplate is the classic Erubis template, augmented with
      # SafeBufferEnhancer.
      #
      # @api private
      class SafeBufferTemplate < ::Erubis::Eruby
        include SafeBufferEnhancer
      end

      ##
      # Modded ErubisTemplate that doesn't insist in an String as output
      # buffer.
      #
      # @api private
      class Template < Tilt::ErubisTemplate
        def precompiled_preamble(locals)
          old_postamble = super.split("\n")[0..-2]
          [old_postamble, "#{@outvar} = _buf = (#{@outvar} || ActiveSupport::SafeBuffer.new)"].join("\n")
        end
      end
    end
  end
  
  Tilt.prefer Padrino::Erubis::Template, :erb

  if defined? Padrino::Rendering
    Padrino::Rendering.engine_configurations[:erb] = 
      {:engine_class => Padrino::Erubis::SafeBufferTemplate}
  end
rescue LoadError
end