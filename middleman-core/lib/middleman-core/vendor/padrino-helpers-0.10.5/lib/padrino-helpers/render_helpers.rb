module Padrino
  module Helpers
    ##
    # Helpers related to rendering within templates (i.e partials).
    #
    module RenderHelpers
      ##
      # Render a partials with collections support
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
      #   Explicit rendering engine to use for this partial
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
      # @api public
      def partial(template, options={})
        options.reverse_merge!(:locals => {}, :layout => false)
        path            = template.to_s.split(File::SEPARATOR)
        object_name     = path[-1].to_sym
        path[-1]        = "_#{path[-1]}"
        explicit_engine = options.delete(:engine)
        template_path   = File.join(path).to_sym
        raise 'Partial collection specified but is nil' if options.has_key?(:collection) && options[:collection].nil?
        if collection = options.delete(:collection)
          options.delete(:object)
          counter = 0
          collection.map { |member|
            counter += 1
            options[:locals].merge!(object_name => member, "#{object_name}_counter".to_sym => counter)
            render(explicit_engine, template_path, options.dup)
          }.join("\n")
        else
          if member = options.delete(:object)
            options[:locals].merge!(object_name => member)
          end
          render(explicit_engine, template_path, options.dup)
        end
      end
      alias :render_partial :partial
    end # RenderHelpers
  end # Helpers
end # Padrino
