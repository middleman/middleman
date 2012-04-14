module Padrino
  module Helpers
    module FormBuilder # @private
      class AbstractFormBuilder # @private
        attr_accessor :template, :object

        def initialize(template, object, options={})
          @template = template
          @object   = build_object(object)
          @options  = options
          raise "FormBuilder template must be initialized!" unless template
          raise "FormBuilder object must not be a nil value. If there's no object, use a symbol instead! (i.e :user)" unless object
        end

        # f.error_messages
        def error_messages(*params)
          params.unshift object
          @template.error_messages_for(*params)
        end

        # f.error_message_on(field)
        def error_message_on(field, options={})
          @template.error_message_on(object, field, options)
        end

        # f.label :username, :caption => "Nickname"
        def label(field, options={})
          options.reverse_merge!(:caption => "#{field_human_name(field)}: ")
          @template.label_tag(field_id(field), options)
        end

        # f.hidden_field :session_id, :value => "45"
        def hidden_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          @template.hidden_field_tag field_name(field), options
        end

        # f.text_field :username, :value => "(blank)", :id => 'username'
        def text_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.text_field_tag field_name(field), options
        end

       def number_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.number_field_tag field_name(field), options
        end

        def telephone_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.telephone_field_tag field_name(field), options
        end
        alias_method :phone_field, :telephone_field

        def email_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.email_field_tag field_name(field), options
        end

        def search_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.search_field_tag field_name(field), options
        end

        def url_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.url_field_tag field_name(field), options
        end

        # f.text_area :summary, :value => "(enter summary)", :id => 'summary'
        def text_area(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.text_area_tag field_name(field), options
        end

        # f.password_field :password, :id => 'password'
        def password_field(field, options={})
          options.reverse_merge!(:value => field_value(field), :id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.password_field_tag field_name(field), options
        end

        # f.select :color, :options => ['red', 'green'], :include_blank => true
        # f.select :color, :collection => @colors, :fields => [:name, :id]
        def select(field, options={})
          options.reverse_merge!(:id => field_id(field), :selected => field_value(field))
          options.merge!(:class => field_error(field, options))
          @template.select_tag field_name(field), options
        end

        # f.check_box :remember_me, :value => 'true', :uncheck_value => '0'
        def check_box(field, options={})
          unchecked_value = options.delete(:uncheck_value) || '0'
          options.reverse_merge!(:id => field_id(field), :value => '1')
          options.reverse_merge!(:checked => true) if values_matches_field?(field, options[:value])
          html  = @template.hidden_field_tag(options[:name] || field_name(field), :value => unchecked_value, :id => nil)
          html << @template.check_box_tag(field_name(field), options)
        end

        # f.radio_button :gender, :value => 'male'
        def radio_button(field, options={})
          options.reverse_merge!(:id => field_id(field, options[:value]))
          options.reverse_merge!(:checked => true) if values_matches_field?(field, options[:value])
          @template.radio_button_tag field_name(field), options
        end

        # f.file_field :photo, :class => 'avatar'
        def file_field(field, options={})
          options.reverse_merge!(:id => field_id(field))
          options.merge!(:class => field_error(field, options))
          @template.file_field_tag field_name(field), options
        end

        # f.submit "Update", :class => 'large'
        def submit(caption="Submit", options={})
          @template.submit_tag caption, options
        end

        # f.image_submit "buttons/submit.png", :class => 'large'
        def image_submit(source, options={})
          @template.image_submit_tag source, options
        end

        # Supports nested fields for a child model within a form
        # f.fields_for :addresses
        # f.fields_for :addresses, address
        # f.fields_for :addresses, @addresses
        def fields_for(child_association, instance_or_collection=nil, &block)
          default_collection = self.object.send(child_association)
          include_index = default_collection.respond_to?(:each)
          nested_options = { :parent => self, :association => child_association }
          nested_objects = instance_or_collection ? Array(instance_or_collection) : Array(default_collection)
          result = nested_objects.each_with_index.map do |child_instance, index|
            nested_options[:index] = include_index ? index : nil
            @template.fields_for(child_instance,  { :nested => nested_options }, &block)
          end.join("\n")
        end

        protected
          # Returns the known field types for a formbuilder
          def self.field_types
            [:hidden_field, :text_field, :text_area, :password_field, :file_field, :radio_button, :check_box, :select]
          end

          # Returns true if the value matches the value in the field
          # field_has_value?(:gender, 'male')
          def values_matches_field?(field, value)
            value.present? && (field_value(field).to_s == value.to_s || field_value(field).to_s == 'true')
          end

          # Add a :invalid css class to the field if it contain an error
          def field_error(field, options)
            error = @object.errors[field] rescue nil
            error.blank? ? options[:class] : [options[:class], :invalid].flatten.compact.join(" ")
          end

          # Returns the human name of the field. Look that use builtin I18n.
          def field_human_name(field)
            I18n.translate("#{object_model_name}.attributes.#{field}", :count => 1, :default => field.to_s.humanize, :scope => :models)
          end

          # Returns the name for the given field
          # field_name(:username) => "user[username]"
          # field_name(:number) => "user[telephone_attributes][number]"
          # field_name(:street) => "user[addresses_attributes][0][street]"
          def field_name(field=nil)
            result = []
            if root_form?
              result << object_model_name
            elsif nested_form?
              parent_form = @options[:nested][:parent]
              attributes_name = "#{@options[:nested][:association]}_attributes"
              nested_index = @options[:nested][:index]
              fragment = [parent_form.field_name, "[#{attributes_name}", "]"]
              fragment.insert(2, "][#{nested_index}") if nested_index
              result << fragment
            end
            result << "[#{field}]" unless field.blank?
            result.flatten.join
          end

          # Returns the id for the given field
          # field_id(:username) => "user_username"
          # field_id(:gender, :male) => "user_gender_male"
          # field_name(:number) => "user_telephone_attributes_number"
          # field_name(:street) => "user_addresses_attributes_0_street"
          def field_id(field=nil, value=nil)
            result = []
            if root_form?
              result << object_model_name
            elsif nested_form?
              parent_form = @options[:nested][:parent]
              attributes_name = "#{@options[:nested][:association]}_attributes"
              nested_index = @options[:nested][:index]
              fragment = [parent_form.field_id, "_#{attributes_name}"]
              fragment.push("_#{nested_index}") if nested_index
              result << fragment
            end
            result << "_#{field}" unless field.blank?
            result << "_#{value}" unless value.blank?
            result.flatten.join
          end

          # Returns the child object if it exists
          def nested_object_id
            nested_form? && object.respond_to?(:new_record?) && !object.new_record? && object.id
          end

          # Returns true if this form object is nested in a parent form
          def nested_form?
            @options[:nested] && @options[:nested][:parent] && @options[:nested][:parent].respond_to?(:object)
          end

          # Returns the value for the object's field
          # field_value(:username) => "Joey"
          def field_value(field)
            @object && @object.respond_to?(field) ? @object.send(field) : ""
          end

          # explicit_object is either a symbol or a record
          # Returns a new record of the type specified in the object
          def build_object(object_or_symbol)
            object_or_symbol.is_a?(Symbol) ? @template.instance_variable_get("@#{object_or_symbol}") || object_class(object_or_symbol).new : object_or_symbol
          end

           # Returns the object's models name
          #   => user_assignment
          def object_model_name(explicit_object=object)
            explicit_object.is_a?(Symbol) ? explicit_object : explicit_object.class.to_s.underscore.gsub(/\//, '_')
          end

          # Returns the class type for the given object
          def object_class(explicit_object)
            explicit_object.is_a?(Symbol) ? explicit_object.to_s.camelize.constantize : explicit_object.class
          end

          # Returns true if this form is the top-level (not nested)
          def root_form?
            !nested_form?
          end
      end # AbstractFormBuilder
    end # FormBuilder
  end # Helpers
end # Padrino
