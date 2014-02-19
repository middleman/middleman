module Padrino
  module Helpers
    ##
    # Helpers related to rendering within templates (i.e partials).
    #
    module RenderHelpers
      ##
      # Render a partials with collections support.
      #
      # @param [String] template
      #   Relative path to partial template.
      # @param [Hash] options
      #   Options hash for rendering options.
      # @option options [Object] :object
      #   Object rendered in partial.
      # @option options [Array<Object>] :collection
      #   Partial is rendered for each object in this collection.
      # @option options [Hash] :locals ({})
      #   Local variables accessible in the partial.
      # @option options [Symbol] :engine
      #   Explicit rendering engine to use for this partial.
      #
      # @return [String] The html generated from this partial.
      #
      # @example
      #   partial 'photo/item', :object => @photo
      #   partial 'photo/item', :collection => @photos
      #   partial 'photo/item', :locals => { :foo => :bar }
      #   partial 'photo/item', :engine => :erb
      #
      # @note If using this from Sinatra, pass explicit +:engine+ option
      #
      def partial(template, options={}, &block)
        options = options.reverse_merge(:locals => {}, :layout => false)
        explicit_engine = options.delete(:engine)

        path,_,name = template.to_s.rpartition(File::SEPARATOR)
        template_path = File.join(path,"_#{name}").to_sym
        object_name = name.to_sym

        objects, counter = if options[:collection].respond_to?(:inject)
          [options.delete(:collection), 0]
        else
          [[options.delete(:object)], nil]
        end

        locals = options[:locals]
        objects.inject(''.html_safe) do |html,object|
          locals[object_name] = object if object
          locals["#{object_name}_counter".to_sym] = counter += 1 if counter
          if block_given?
            output = render(explicit_engine, template_path, options){ capture_html(&block) }.html_safe
            html << (block_is_template?(block) ? concat_content(output) : output)
          else
            html << render(explicit_engine, template_path, options).html_safe
          end
        end
      end
      alias :render_partial :partial
    end
  end
end
