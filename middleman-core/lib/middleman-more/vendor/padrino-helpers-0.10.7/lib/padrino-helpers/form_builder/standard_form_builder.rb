require File.expand_path(File.dirname(__FILE__) + '/abstract_form_builder') unless defined?(AbstractFormBuilder)

module Padrino
  module Helpers
    module FormBuilder # @private
      class StandardFormBuilder < AbstractFormBuilder # @private

        ##
        # StandardFormBuilder
        #
        #   text_field_block(:username, { :class => 'long' }, { :class => 'wide-label' })
        #   text_area_block(:summary, { :class => 'long' }, { :class => 'wide-label' })
        #   password_field_block(:password, { :class => 'long' }, { :class => 'wide-label' })
        #   file_field_block(:photo, { :class => 'long' }, { :class => 'wide-label' })
        #   check_box_block(:remember_me, { :class => 'long' }, { :class => 'wide-label' })
        #   select_block(:color, :options => ['green', 'black'])
        #
        (self.field_types - [ :hidden_field, :radio_button ]).each do |field_type|
          class_eval <<-EOF
          def #{field_type}_block(field, options={}, label_options={})
            label_options.reverse_merge!(:caption => options.delete(:caption)) if options[:caption]
            field_html = label(field, label_options)
            field_html << #{field_type}(field, options)
            @template.content_tag(:p, field_html)
          end
          EOF
        end

        # submit_block("Update")
        def submit_block(caption, options={})
          submit_html = self.submit(caption, options)
          @template.content_tag(:p, submit_html)
        end

        # image_submit_block("submit.png")
        def image_submit_block(source, options={})
          submit_html = self.image_submit(source, options)
          @template.content_tag(:p, submit_html)
        end
      end # StandardFormBuilder
    end # FormBuilder
  end # Helpers
end # Padrino
