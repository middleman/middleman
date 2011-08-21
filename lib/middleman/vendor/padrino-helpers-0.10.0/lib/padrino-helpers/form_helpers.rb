module Padrino
  module Helpers
    module FormHelpers
      ##
      # Constructs a form for object using given or default form_builder
      #
      # ==== Examples
      #
      #   form_for :user, '/register' do |f| ... end
      #   form_for @user, '/register', :id => 'register' do |f| ... end
      #
      def form_for(object, url, settings={}, &block)
        form_html = capture_html(builder_instance(object, settings), &block)
        form_tag(url, settings) { form_html }
      end

      ##
      # Constructs form fields for an object using given or default form_builder
      # Used within an existing form to allow alternate objects within one form
      #
      # ==== Examples
      #
      #   fields_for @user.assignment do |assignment| ... end
      #   fields_for :assignment do |assigment| ... end
      #
      def fields_for(object, settings={}, &block)
        instance = builder_instance(object, settings)
        fields_html = capture_html(instance, &block)
        fields_html << instance.hidden_field(:id) if instance.send(:nested_object_id)
        concat_content fields_html
      end

      ##
      # Constructs a form without object based on options
      #
      # ==== Examples
      #
      #   form_tag '/register' do ... end
      #
      def form_tag(url, options={}, &block)
        desired_method = options[:method]
        data_method = options.delete(:method) if options[:method].to_s !~ /get|post/i
        options.reverse_merge!(:method => "post", :action => url)
        options[:enctype] = "multipart/form-data" if options.delete(:multipart)
        options["data-remote"] = "true" if options.delete(:remote)
        options["data-method"] = data_method if data_method
        options["accept-charset"] ||= "UTF-8"
        inner_form_html  = hidden_form_method_field(desired_method)
        inner_form_html += capture_html(&block)
        concat_content content_tag(:form, inner_form_html, options)
      end

      ##
      # Returns the hidden method field for 'put' and 'delete' forms
      # Only 'get' and 'post' are allowed within browsers;
      # 'put' and 'delete' are just specified using hidden fields with form action still 'put'.
      #
      # ==== Examples
      #
      #   # Generate: <input name="_method" value="delete" />
      #   hidden_form_method_field('delete')
      #
      def hidden_form_method_field(desired_method)
        return '' if desired_method.blank? || desired_method.to_s =~ /get|post/i
        hidden_field_tag(:_method, :value => desired_method)
      end

      ##
      # Constructs a field_set to group fields with given options
      #
      # ==== Examples
      #
      #   field_set_tag("Office", :class => 'office-set')
      #
      def field_set_tag(*args, &block)
        options = args.extract_options!
        legend_text = args[0].is_a?(String) ? args.first : nil
        legend_html = legend_text.blank? ? '' : content_tag(:legend, legend_text)
        field_set_content = legend_html + capture_html(&block)
        concat_content content_tag(:fieldset, field_set_content, options)
      end

      ##
      # Constructs list html for the errors for a given symbol
      #
      # ==== Options
      #
      # :header_tag:: Used for the header of the error div (default: "h2").
      # :id:: The id of the error div (default: "errorExplanation").
      # :class:: The class of the error div (default: "errorExplanation").
      # :object:: The object (or array of objects) for which to display errors,
      # if you need to escape the instance variable convention.
      # :object_name:: The object name to use in the header, or any text that you prefer.
      # If +:object_name+ is not set, the name of the first object will be used.
      # :header_message:: The message in the header of the error div.  Pass +nil+
      # or an empty string to avoid the header message altogether. (Default: "X errors
      # prohibited this object from being saved").
      # :message:: The explanation message after the header message and before
      # the error list.  Pass +nil+ or an empty string to avoid the explanation message
      # altogether. (Default: "There were problems with the following fields:").
      #
      # ==== Examples
      #
      #   error_messages_for :user
      #
      def error_messages_for(*objects)
        options = objects.extract_options!.symbolize_keys
        objects = objects.map {|object_name| object_name.is_a?(Symbol) ? instance_variable_get("@#{object_name}") : object_name }.compact
        count   = objects.inject(0) {|sum, object| sum + object.errors.size }

        unless count.zero?
          html = {}
          [:id, :class, :style].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'field-errors' unless key == :style
            end
          end

          options[:object_name] ||= objects.first.class

          I18n.with_options :locale => options[:locale], :scope => [:models, :errors, :template] do |locale|
            header_message = if options.include?(:header_message)
              options[:header_message]
            else
              object_name = options[:object_name].to_s.underscore.gsub(/\//, ' ')
              object_name = I18n.t(:name, :default => object_name.humanize, :scope => [:models, object_name], :count => 1)
              locale.t :header, :count => count, :model => object_name
            end
            message = options.include?(:message) ? options[:message] : locale.t(:body)
            error_messages = objects.map { |object|
              object_name = options[:object_name].to_s.underscore.gsub(/\//, ' ')
              object.errors.map { |f, msg|
                field = I18n.t(f, :default => f.to_s.humanize, :scope => [:models, object_name, :attributes])
                content_tag(:li, "%s %s" % [field, msg])
              }
            }.join

            contents = ''
            contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
            contents << content_tag(:p, message) unless message.blank?
            contents << content_tag(:ul, error_messages)

            content_tag(:div, contents, html)
          end
        else
          ''
        end
      end

      ##
      # Returns a string containing the error message attached to the +method+ on the +object+ if one exists.
      #
      # ==== Options
      #
      # :tag::      The tag that enclose your error. (Default 'div')
      # :prepend::  Text to add before error.
      # :append::   Text to add after error.
      #
      # ==== Examples
      #
      #   # => <span class="error">can't be blank</div>
      #   error_message_on :post, :title
      #   error_message_on @post, :title
      #
      #   # => <div class="custom" style="border:1px solid red">can't be blank</div>
      #   error_message_on :post, :title, :tag => :id, :class => :custom, :style => "border:1px solid red"
      #
      #   # => <div class="error">This title can't be blank (or it won't work)</div>
      #   error_message_on :post, :title, :prepend => "This title", :append => "(or it won't work)"
      #
      def error_message_on(object, field, options={})
        object = object.is_a?(Symbol) ? instance_variable_get("@#{object}") : object
        error  = object.errors[field] rescue nil
        if error
          options.reverse_merge!(:tag => :span, :class => :error)
          tag   = options.delete(:tag)
          # Array(error).first is necessary because some orm give us an array others directly a value
          error = [options.delete(:prepend), Array(error).first, options.delete(:append)].compact.join(" ")
          content_tag(tag, error, options)
        else
          ''
        end
      end

      ##
      # Constructs a label tag from the given options
      #
      # ==== Examples
      #
      #   label_tag :username, :class => 'long-label'
      #   label_tag :username, :class => 'long-label' do ... end
      #
      def label_tag(name, options={}, &block)
        options.reverse_merge!(:caption => "#{name.to_s.humanize}: ", :for => name)
        caption_text = options.delete(:caption)
        caption_text << "<span class='required'>*</span> " if options.delete(:required)
        if block_given? # label with inner content
          label_content = caption_text + capture_html(&block)
          concat_content(content_tag(:label, label_content, options))
        else # regular label
          content_tag(:label, caption_text, options)
        end
      end

      ##
      # Constructs a hidden field input from the given options
      #
      # ==== Examples
      #
      #   hidden_field_tag :session_key, :value => "__secret__"
      #
      def hidden_field_tag(name, options={})
        options.reverse_merge!(:name => name)
        input_tag(:hidden, options)
      end

      ##
      # Constructs a text field input from the given options
      #
      # ==== Examples
      #
      #   text_field_tag :username, :class => 'long'
      #
      def text_field_tag(name, options={})
        options.reverse_merge!(:name => name)
        input_tag(:text, options)
      end

      ##
      # Constructs a text area input from the given options
      #
      # ==== Examples
      #
      #   text_area_tag :username, :class => 'long', :value => "Demo?"
      #
      def text_area_tag(name, options={})
        options.reverse_merge!(:name => name, :rows => "", :cols => "")
        content_tag(:textarea, options.delete(:value).to_s, options)
      end

      ##
      # Constructs a password field input from the given options
      #
      # ==== Examples
      #
      #   password_field_tag :password, :class => 'long'
      #
      def password_field_tag(name, options={})
        options.reverse_merge!(:name => name)
        input_tag(:password, options)
      end

      ##
      # Constructs a select from the given options
      #
      # ==== Examples
      #
      #   options = [['caption', 'value'], ['Green', 'green1'], ['Blue', 'blue1'], ['Black', "black1"]]
      #   options = ['option', 'red', 'yellow' ]
      #   select_tag(:favorite_color, :options => ['red', 'yellow'], :selected => 'green1')
      #   select_tag(:country, :collection => @countries, :fields => [:name, :code], :include_blank => 'None')
      #
      #   # Optgroups can be generated using :grouped_options => (Hash or nested Array)
      #   grouped_options = [['Friends',['Yoda',['Obiwan',1]]],['Enemies',['Palpatine',['Darth Vader',3]]]]
      #   grouped_options = {'Friends' => ['Yoda',['Obiwan',1]],'Enemies' => ['Palpatine',['Darth Vader',3]]}
      #   select_tag(:color, :grouped_options => [['warm',['red','yellow']],['cool',['blue', 'purple']]])
      #
      #   # Optgroups can be generated using :grouped_options => (Hash or nested Array)
      #   grouped_options = [['Friends',['Yoda',['Obiwan',1]]],['Enemies',['Palpatine',['Darth Vader',3]]]]
      #   grouped_options = {'Friends' => ['Yoda',['Obiwan',1]],'Enemies' => ['Palpatine',['Darth Vader',3]]}
      #   select_tag(:color, :grouped_options => [['warm',['red','yellow']],['cool',['blue', 'purple']]])
      #
      def select_tag(name, options={})
        options.reverse_merge!(:name => name)
        collection, fields = options.delete(:collection), options.delete(:fields)
        options[:options] = options_from_collection(collection, fields) if collection
        prompt = options.delete(:include_blank)
        select_options_html = if options[:options]
          options_for_select(options.delete(:options), options.delete(:selected))
        elsif options[:grouped_options]
          grouped_options_for_select(options.delete(:grouped_options), options.delete(:selected), prompt)
        end
        select_options_html = select_options_html.unshift(blank_option(prompt)) if select_options_html.is_a?(Array)
        options.merge!(:name => "#{options[:name]}[]") if options[:multiple]
        content_tag(:select, select_options_html, options)
      end

      ##
      # Constructs a check_box from the given options
      #
      # ==== Examples
      #
      #   check_box_tag :remember_me, :value => 'Yes'
      #
      def check_box_tag(name, options={})
        options.reverse_merge!(:name => name, :value => '1')
        input_tag(:checkbox, options)
      end

      ##
      # Constructs a radio_button from the given options
      #
      # ==== Examples
      #
      #   radio_button_tag :remember_me, :value => 'true'
      #
      def radio_button_tag(name, options={})
        options.reverse_merge!(:name => name)
        input_tag(:radio, options)
      end

      ##
      # Constructs a file field input from the given options
      #
      # ==== Examples
      #
      #   file_field_tag :photo, :class => 'long'
      #
      def file_field_tag(name, options={})
        options.reverse_merge!(:name => name)
        input_tag(:file, options)
      end

      ##
      # Constructs a submit button from the given options
      #
      # ==== Examples
      #
      #   submit_tag "Create", :class => 'success'
      #
      def submit_tag(caption="Submit", options={})
        options.reverse_merge!(:value => caption)
        input_tag(:submit, options)
      end

      ##
      # Constructs a button input from the given options
      #
      # ==== Examples
      #
      #   button_tag "Cancel", :class => 'clear'
      #
      def button_tag(caption, options = {})
        options.reverse_merge!(:value => caption)
        input_tag(:button, options)
      end

      # Constructs a submit button from the given options
      #
      # ==== Examples
      #
      #   submit_tag "Create", :class => 'success'
      #
      def image_submit_tag(source, options={})
        options.reverse_merge!(:src => image_path(source))
        input_tag(:image, options)
      end

      ##
      # Returns an array of option items for a select field based on the given collection
      # fields is an array containing the fields to display from each item in the collection
      #
      def options_from_collection(collection, fields)
        collection.map { |item| [ item.send(fields.first), item.send(fields.last) ] }
      end

      #
      # Returns the options tags for a select based on the given option items
      #
      def options_for_select(option_items, selected_value=nil)
        return '' if option_items.blank?
        option_items.map do |caption, value|
          value ||= caption
          content_tag(:option, caption, :value => value, :selected => option_is_selected?(value, caption, selected_value))
        end
      end

      #
      # Returns the optgroups with options tags for a select based on the given :grouped_options items
      #
      def grouped_options_for_select(collection,selected=nil,prompt=false)
        if collection.is_a?(Hash)
          collection.map do |key, value|
            content_tag :optgroup, :label => key do
              options_for_select(value, selected)
            end
          end
        elsif collection.is_a?(Array)
          collection.map do |optgroup|
            content_tag :optgroup, :label => optgroup.first do
              options_for_select(optgroup.last, selected)
            end
          end
        end
      end

      #
      # Returns the blank option serving as a prompt if passed
      #
      def blank_option(prompt)
        return unless prompt
        case prompt
          when String then content_tag(:option, prompt,       :value => '')
          when Array  then content_tag(:option, prompt.first, :value => prompt.last)
          else             content_tag(:option, '',           :value => '')
        end
      end

      private
        ##
        # Returns the FormBuilder class to use based on all available setting sources
        # If explicitly defined, returns that, otherwise returns defaults.
        #
        #   configured_form_builder_class(nil) => StandardFormBuilder
        #
        def configured_form_builder_class(explicit_builder=nil)
          default_builder    = self.respond_to?(:settings) && self.settings.default_builder
          configured_builder = explicit_builder || default_builder || 'StandardFormBuilder'
          configured_builder = "Padrino::Helpers::FormBuilder::#{configured_builder}".constantize if configured_builder.is_a?(String)
          configured_builder
        end

        ##
        # Returns an initialized builder instance for the given object and settings
        #
        #   builder_instance(@account, :nested => { ... }) => <FormBuilder>
        #
        def builder_instance(object, settings={})
           builder_class = configured_form_builder_class(settings.delete(:builder))
           builder_class.new(self, object, settings)
        end

        ##
        # Returns whether the option should be selected or not
        #
        def option_is_selected?(value, caption, selected_values)
          Array(selected_values).any? do |selected|
            [value.to_s, caption.to_s].include?(selected.to_s)
          end
        end
    end # FormHelpers
  end # Helpers
end # Padrino