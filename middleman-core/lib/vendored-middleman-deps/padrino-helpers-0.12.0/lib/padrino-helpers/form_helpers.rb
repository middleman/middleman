require 'securerandom'

module Padrino
  module Helpers
    ##
    # Helpers related to producing form related tags and inputs into templates.
    #
    module FormHelpers
      ##
      # Constructs a form for object using given or default form_builder.
      #
      # @param [Object] object
      #   The object for which the form is being built.
      # @param [String] URL
      #   The url this form will submit to.
      # @param [Hash] settings
      #   The settings associated with this form.
      #   Accepts a :namespace option that will be prepended to the id attributes of the form's elements.
      #   Also accepts HTML options.
      # @option settings [String] :builder ("StandardFormBuilder")
      #   The FormBuilder class to use such as StandardFormBuilder.
      # @option settings [Symbol] :as
      #   Sets custom form object name.
      # @param [Proc] block
      #   The fields and content inside this form.
      #
      # @yield [AbstractFormBuilder] The form builder used to compose fields.
      #
      # @return [String] The html object-backed form with the specified options and input fields.
      #
      # @example
      #   form_for :user, '/register' do |f| ... end
      #   form_for @user, '/register', :id => 'register' do |f| ... end
      #   form_for @user, '/register', :as => :customer do |f| ... end
      #
      def form_for(object, url, settings={}, &block)
        instance = builder_instance(object, settings)
        html = capture_html(instance, &block)
        settings[:multipart] = instance.multipart unless settings.include?(:multipart)
        settings.delete(:namespace)
        settings.delete(:as)
        form_tag(url, settings) { html }
      end

      ##
      # Constructs form fields for an object using given or default form_builder.
      # Used within an existing form to allow alternate objects within one form.
      #
      # @param [Object] object
      #   The object for which the fields are being built.
      # @param [Hash] settings
      #   The settings associated with these fields. Accepts HTML options.
      # @param [Proc] block
      #   The content inside this set of fields.
      #
      # @return [String] The html fields with the specified options.
      #
      # @example
      #   fields_for @user.assignment do |assignment| ... end
      #   fields_for :assignment do |assigment| ... end
      #
      def fields_for(object, settings={}, &block)
        instance = builder_instance(object, settings)
        fields_html = capture_html(instance, &block)
        fields_html << instance.hidden_field(:id) if instance.send(:nested_object_id)
        concat_safe_content fields_html
      end

      ##
      # Constructs a form without object based on options.
      #
      # @param [String] url
      #   The URL this form will submit to.
      # @param [Hash] options
      #   The html options associated with this form.
      # @param [Proc] block
      #   The fields and content inside this form.
      #
      # @return [String] The HTML form with the specified options and input fields.
      #
      # @example
      #   form_tag '/register', :class => "registration_form" do ... end
      #
      def form_tag(url, options={}, &block)
        options = options.dup
        desired_method = options[:method].to_s
        options.delete(:method) unless desired_method =~ /get|post/i
        options.reverse_merge!(:method => 'post',
                               :action => url,
                               :protect_from_csrf => is_protected_from_csrf? )
        options[:enctype] = 'multipart/form-data' if options.delete(:multipart)
        options['accept-charset'] ||= 'UTF-8'
        inner_form_html = hidden_form_method_field(desired_method)
        if options[:protect_from_csrf] == true && !(desired_method =~ /get/i)
          inner_form_html << csrf_token_field
        end
        inner_form_html << mark_safe(capture_html(&block))
        concat_content content_tag(:form, inner_form_html, options)
      end

      ##
      # Returns the hidden method field for 'put' and 'delete' forms.
      # Only 'get' and 'post' are allowed within browsers;
      # 'put' and 'delete' are just specified using hidden fields with form action still 'put'.
      #
      # @param [String] desired_method
      #   The method this hidden field represents (i.e put or delete).
      #
      # @return [String] The hidden field representing the +desired_method+ for the form.
      #
      # @example
      #   # Generate: <input name="_method" value="delete" />
      #   hidden_form_method_field('delete')
      #
      def hidden_form_method_field(desired_method)
        return ActiveSupport::SafeBuffer.new if desired_method.blank? || desired_method.to_s =~ /get|post/i
        hidden_field_tag(:_method, :value => desired_method)
      end

      ##
      # Constructs a field_set to group fields with given options.
      #
      # @overload field_set_tag(legend=nil, options={}, &block)
      #   @param [String] legend  The legend caption for the fieldset
      #   @param [Hash]   options The html options for the fieldset.
      #   @param [Proc]   block   The content inside the fieldset.
      # @overload field_set_tag(options={}, &block)
      #   @param [Hash]   options The html options for the fieldset.
      #   @param [Proc]   block   The content inside the fieldset.
      #
      # @return [String] The html for the fieldset tag based on given +options+.
      #
      # @example
      #   field_set_tag(:class => "office-set") { }
      #   field_set_tag("Office", :class => 'office-set') { }
      #
      def field_set_tag(*args, &block)
        options = args.extract_options!
        legend_text = args[0].is_a?(String) ? args.first : nil
        legend_html = legend_text.blank? ? ActiveSupport::SafeBuffer.new : content_tag(:legend, legend_text)
        field_set_content = legend_html + mark_safe(capture_html(&block))
        concat_content content_tag(:fieldset, field_set_content, options)
      end

      ##
      # Constructs list HTML for the errors for a given symbol.
      #
      # @overload error_messages_for(*objects, options = {})
      #   @param [Array<Object>]  object   Splat of objects to display errors for.
      #   @param [Hash]           options  Error message display options.
      #   @option options [String] :header_tag ("h2")
      #     Used for the header of the error div.
      #   @option options [String] :id ("field-errors")
      #     The id of the error div.
      #   @option options [String] :class ("field-errors")
      #     The class of the error div.
      #   @option options [Array<Object>]  :object
      #     The object (or array of objects) for which to display errors,
      #     if you need to escape the instance variable convention.
      #   @option options [String] :object_name
      #     The object name to use in the header, or any text that you prefer.
      #     If +:object_name+ is not set, the name of the first object will be used.
      #   @option options [String] :header_message ("X errors prohibited this object from being saved")
      #     The message in the header of the error div. Pass +nil+ or an empty string
      #     to avoid the header message altogether.
      #   @option options [String] :message ("There were problems with the following fields:")
      #     The explanation message after the header message and before
      #     the error list.  Pass +nil+ or an empty string to avoid the explanation message
      #     altogether.
      #
      # @return [String] The html section with all errors for the specified +objects+
      #
      # @example
      #   error_messages_for :user
      #
      def error_messages_for(*objects)
        options = objects.extract_options!.symbolize_keys
        objects = objects.map{ |obj| resolve_object(obj) }.compact
        count   = objects.inject(0){ |sum, object| sum + object.errors.count }
        return ''.html_safe if count.zero?

        html_options = {}
        [:id, :class, :style].each do |key|
          if options.include?(key)
            value = options[key]
            html_options[key] = value unless value.blank?
          else
            html_options[key] = 'field-errors' unless key == :style
          end
        end

        I18n.with_options :locale => options[:locale], :scope => [:models, :errors, :template] do |locale|
          object_name = options[:object_name] || objects.first.class.to_s.underscore.gsub(/\//, ' ')

          header_message = if options.include?(:header_message)
            options[:header_message]
          else
            model_name = I18n.t(:name, :default => object_name.humanize, :scope => [:models, object_name], :count => 1)
            locale.t :header, :count => count, :model => model_name
          end

          body_message = options[:message] || locale.t(:body)

          error_messages = objects.inject(''.html_safe) do |text, object|
            object.errors.each do |field, message|
              field_name = I18n.t(field, :default => field.to_s.humanize, :scope => [:models, object_name, :attributes])
              text << content_tag(:li, "#{field_name} #{message}")
            end
            text
          end

          contents = ActiveSupport::SafeBuffer.new
          contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
          contents << content_tag(:p, body_message) unless body_message.blank?
          contents << content_tag(:ul, error_messages)
          content_tag(:div, contents, html_options)
        end
      end

      ##
      # Returns a string containing the error message attached to the
      # +method+ on the +object+ if one exists.
      #
      # @param [Object] object
      #   The object to display the error for.
      # @param [Symbol] field
      #   The field on the +object+ to display the error for.
      # @param [Hash] options
      #   The options to control the error display.
      # @option options [String] :tag ("span")
      #   The tag that encloses the error.
      # @option options [String] :prepend ("")
      #   The text to prepend before the field error.
      # @option options [String] :append ("")
      #   The text to append after the field error.
      #
      # @example
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
      # @return [String] The html display of an error for a particular +object+ and +field+.
      #
      # @api public
      def error_message_on(object, field, options={})
        error = Array(resolve_object(object).errors[field]).first
        return ''.html_safe unless error
        options = options.reverse_merge(:tag => :span, :class => :error)
        tag   = options.delete(:tag)
        error = [options.delete(:prepend), error, options.delete(:append)].compact.join(" ")
        content_tag(tag, error, options)
      end

      ##
      # Constructs a label tag from the given options.
      #
      # @param [String] name
      #   The name of the field to label.
      # @param [Hash] options
      #   The html options for this label.
      # @option options :caption
      #   The caption for this label.
      # @param [Proc] block
      #   The content to be inserted into the label.
      #
      # @return [String] The html for this label with the given +options+.
      #
      # @example
      #   label_tag :username, :class => 'long-label'
      #   label_tag :username, :class => 'long-label' do ... end
      #
      def label_tag(name, options={}, &block)
        options = options.reverse_merge(:caption => "#{name.to_s.humanize}: ", :for => name)
        caption_text = ''.html_safe
        caption_text.concat options.delete(:caption)
        caption_text.safe_concat "<span class='required'>*</span> " if options.delete(:required)

        if block_given?
          label_content = caption_text.concat capture_html(&block)
          concat_content(content_tag(:label, label_content, options))
        else
          content_tag(:label, caption_text, options)
        end
      end

      ##
      # Creates a text field input with the given name and options.
      #
      # @macro [new] text_field
      #   @param [Symbol] name
      #     The name of the input to create.
      #   @param [Hash] options
      #     The HTML options to include in this field.
      #
      #   @option options [String] :id
      #     Specifies a unique identifier for the field.
      #   @option options [String] :class
      #     Specifies the stylesheet class of the field.
      #   @option options [String] :name
      #     Specifies the name of the field.
      #   @option options [String] :accesskey
      #     Specifies a shortcut key to access the field.
      #   @option options [Integer] :tabindex
      #     Specifies the tab order of the field.
      #   @option options [Integer] :maxlength
      #     Specifies the maximum length, in characters, of the field.
      #   @option options [Integer] :size
      #     Specifies the width, in characters, of the field.
      #   @option options [String] :placeholder
      #     Specifies a short hint that describes the expected value of the field.
      #   @option options [Boolean] :hidden
      #     Specifies whether or not the field is hidden from view.
      #   @option options [Boolean] :spellcheck
      #     Specifies whether or not the field should have it's spelling and grammar checked for errors.
      #   @option options [Boolean] :draggable
      #     Specifies whether or not the field is draggable. (true, false, :auto).
      #   @option options [String] :pattern
      #     Specifies the regular expression pattern that the field's value is checked against.
      #   @option options [Symbol] :autocomplete
      #     Specifies whether or not the field should have autocomplete enabled. (:on, :off).
      #   @option options [Boolean] :autofocus
      #     Specifies whether or not the field should automatically get focus when the page loads.
      #   @option options [Boolean] :required
      #     Specifies whether or not the field is required to be completed before the form is submitted.
      #   @option options [Boolean] :readonly
      #     Specifies whether or not the field is read only.
      #   @option options [Boolean] :disabled
      #     Specifies whether or not the field is disabled.
      #
      #   @return [String]
      #     Generated HTML with specified +options+.
      #
      # @example
      #   text_field_tag :first_name, :maxlength => 40, :required => true
      #   # => <input name="first_name" maxlength="40" required type="text" />
      #
      #   text_field_tag :last_name, :class => 'string', :size => 40
      #   # => <input name="last_name" class="string" size="40" type="text" />
      #
      #   text_field_tag :username, :placeholder => 'Your Username'
      #   # => <input name="username" placeholder="Your Username" type="text" />
      #
      def text_field_tag(name, options={})
        input_tag(:text, options.reverse_merge(:name => name))
      end

      ##
      # Creates a number field input with the given name and options.
      #
      # @macro [new] number_field
      #   @param [Symbol] name
      #     The name of the input to create.
      #   @param [Hash] options
      #     The HTML options to include in this field.
      #
      #   @option options [String] :id
      #     Specifies a unique identifier for the field.
      #   @option options [String] :class
      #     Specifies the stylesheet class of the field.
      #   @option options [String] :name
      #     Specifies the name of the field.
      #   @option options [String] :accesskey
      #     Specifies a shortcut key to access the field.
      #   @option options [Integer] :tabindex
      #     Specifies the tab order of the field.
      #   @option options [Integer] :min
      #     Specifies the minimum value of the field.
      #   @option options [Integer] :max
      #     Specifies the maximum value of the field.
      #   @option options [Integer] :step
      #     Specifies the legal number intervals of the field.
      #   @option options [Boolean] :hidden
      #     Specifies whether or not the field is hidden from view.
      #   @option options [Boolean] :spellcheck
      #     Specifies whether or not the field should have it's spelling and grammar checked for errors.
      #   @option options [Boolean] :draggable
      #     Specifies whether or not the field is draggable. (true, false, :auto).
      #   @option options [String] :pattern
      #     Specifies the regular expression pattern that the field's value is checked against.
      #   @option options [Symbol] :autocomplete
      #     Specifies whether or not the field should have autocomplete enabled. (:on, :off).
      #   @option options [Boolean] :autofocus
      #     Specifies whether or not the field should automatically get focus when the page loads.
      #   @option options [Boolean] :required
      #     Specifies whether or not the field is required to be completeled before the form is submitted.
      #   @option options [Boolean] :readonly
      #     Specifies whether or not the field is read only.
      #   @option options [Boolean] :disabled
      #     Specifies whether or not the field is disabled.
      #
      #   @return [String]
      #     Generated HTML with specified +options+.
      #
      # @example
      #   number_field_tag :quantity, :class => 'numeric'
      #   # => <input name="quantity" class="numeric" type="number" />
      #
      #   number_field_tag :zip_code, :pattern => /[0-9]{5}/
      #   # => <input name="zip_code" pattern="[0-9]{5}" type="number" />
      #
      #   number_field_tag :credit_card, :autocomplete => :off
      #   # => <input name="credit_card" autocomplete="off" type="number" />
      #
      #   number_field_tag :age, :min => 18, :max => 120, :step => 1
      #   # => <input name="age" min="18" max="120" step="1" type="number" />
      #
      def number_field_tag(name, options={})
        input_tag(:number, options.reverse_merge(:name => name))
      end

      ##
      # Creates a telephone field input with the given name and options.
      #
      # @macro text_field
      #
      # @example
      #   telephone_field_tag :phone_number, :class => 'string'
      #   # => <input name="phone_number" class="string" type="tel" />
      #
      #  telephone_field_tag :cell_phone, :tabindex => 1
      #  telephone_field_tag :work_phone, :tabindex => 2
      #  telephone_field_tag :home_phone, :tabindex => 3
      #
      #  # => <input name="cell_phone" tabindex="1" type="tel" />
      #  # => <input name="work_phone" tabindex="2" type="tel" />
      #  # => <input name="home_phone" tabindex="3" type="tel" />
      #
      def telephone_field_tag(name, options={})
        input_tag(:tel, options.reverse_merge(:name => name))
      end
      alias_method :phone_field_tag, :telephone_field_tag

      ##
      # Creates an email field input with the given name and options.
      #
      # @macro text_field
      #
      # @example
      #   email_field_tag :email, :placeholder => 'you@example.com'
      #   # => <input name="email" placeholder="you@example.com" type="email" />
      #
      #   email_field_tag :email, :value => 'padrinorb@gmail.com', :readonly => true
      #   # => <input name="email" value="padrinorb@gmail.com" readonly type="email" />
      #
      def email_field_tag(name, options={})
        input_tag(:email, options.reverse_merge(:name => name))
      end

      ##
      # Creates a search field input with the given name and options.
      #
      # @macro text_field
      #
      # @example
      #  search_field_tag :search, :placeholder => 'Search this website...'
      #  # => <input name="search" placeholder="Search this website..." type="search" />
      #
      #  search_field_tag :search, :maxlength => 15, :class => ['search', 'string']
      #  # => <input name="search" maxlength="15" class="search string" />
      #
      #  search_field_tag :search, :id => 'search'
      #  # => <input name="search" id="search" type="search" />
      #
      #  search_field_tag :search, :autofocus => true
      #  # => <input name="search" autofocus type="search" />
      #
      def search_field_tag(name, options={})
        input_tag(:search, options.reverse_merge(:name => name))
      end

      ##
      # Creates a URL field input with the given name and options.
      #
      # @macro text_field
      #
      # @example
      #  url_field_tag :favorite_website, :placeholder => 'http://padrinorb.com'
      #  <input name="favorite_website" placeholder="http://padrinorb.com." type="url" />
      #
      #  url_field_tag :home_page, :class => 'string url'
      #  <input name="home_page" class="string url", type="url" />
      #
      def url_field_tag(name, options={})
        input_tag(:url, options.reverse_merge(:name => name))
      end

      ##
      # Constructs a hidden field input from the given options.
      #
      # @example
      #   hidden_field_tag :session_key, :value => "__secret__"
      #
      def hidden_field_tag(name, options={})
        input_tag(:hidden, options.reverse_merge(:name => name))
      end

      ##
      # Constructs a text area input from the given options.
      #
      # @example
      #   text_area_tag :username, :class => 'long', :value => "Demo?"
      #
      def text_area_tag(name, options={})
        options = options.reverse_merge(:name => name, :rows => "", :cols => "")
        content_tag(:textarea, options.delete(:value).to_s, options)
      end

      ##
      # Constructs a password field input from the given options.
      #
      # @example
      #   password_field_tag :password, :class => 'long'
      #
      # @api public
      def password_field_tag(name, options={})
        input_tag(:password, options.reverse_merge(:name => name))
      end

      ##
      # Constructs a check_box from the given options.
      #
      # @example
      #   check_box_tag :remember_me, :value => 'Yes'
      #
      def check_box_tag(name, options={})
        input_tag(:checkbox, options.reverse_merge(:name => name, :value => '1'))
      end

      ##
      # Constructs a radio_button from the given options.
      #
      # @example
      #   radio_button_tag :remember_me, :value => 'true'
      #
      def radio_button_tag(name, options={})
        input_tag(:radio, options.reverse_merge(:name => name))
      end

      ##
      # Constructs a file field input from the given options.
      #
      # @example
      #   file_field_tag :photo, :class => 'long'
      #
      # @api public
      def file_field_tag(name, options={})
        name = "#{name}[]" if options[:multiple]
        input_tag(:file, options.reverse_merge(:name => name))
      end

      ##
      # Constructs a select from the given options.
      #
      # @example
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
      # @param [String] name
      #   The name of the input field.
      # @param [Hash] options
      #   The html options for the input field.
      # @option options [Array<String, Array>] :options
      #  Explicit options to display in the select. Can be strings or string tuples.
      # @option options [Array<Array>] :grouped_options
      #   List of options for each group in the select. See examples for details.
      # @option options [Array<Object>] :collection
      #   Collection of objects used as options in the select.
      # @option options [Array<Symbol>] :fields
      #   The attributes used as "label" and "value" for each +collection+ object.
      # @option options [String] :selected (nil)
      #   The option value initially selected.
      # @option options [Boolean] :include_blank (false)
      #   Include a blank option in the select.
      # @option options [Boolean] :multiple (false)
      #   Allow multiple options to be selected at once.
      #
      # @return [String] The HTML input field based on the +options+ specified.
      #
      def select_tag(name, options={})
        options = options.reverse_merge(:name => name)
        options[:name] = "#{options[:name]}[]" if options[:multiple]
        collection, fields = options.delete(:collection), options.delete(:fields)
        options[:options] = options_from_collection(collection, fields) if collection
        options_tags = extract_option_tags!(options)
        content_tag(:select, options_tags, options)
      end

      ##
      # Constructs a button input from the given options.
      #
      # @param [String] caption
      #   The caption for the button.
      # @param [Hash] options
      #   The html options for the input field.
      #
      # @return [String] The html button based on the +options+ specified.
      #
      # @example
      #   button_tag "Cancel", :class => 'clear'
      #
      def button_tag(caption, options = {})
        input_tag(:button, options.reverse_merge(:value => caption))
      end

      ##
      # Constructs a submit button from the given options.
      #
      # @param [String] caption (defaults to: +Submit+)
      #   The caption for the submit button.
      # @param [Hash] options
      #   The html options for the input field.
      #
      # @return [String] The html submit button based on the +options+ specified.
      #
      # @example
      #   submit_tag "Create", :class => 'success'
      #   submit_tag :class => 'btn'
      #
      def submit_tag(*args)
        options = args.extract_options!
        caption = args.length >= 1 ? args.first : "Submit"
        input_tag(:submit, options.reverse_merge(:value => caption))
      end

      ##
      # Constructs a submit button from the given options.
      #
      # @param [String] source
      #   The source image path for the button.
      # @param [Hash] options
      #   The html options for the input field.
      #
      # @return [String] The html image button based on the +options+ specified.
      #
      # @example
      #   image_submit_tag 'form/submit.png'
      #
      def image_submit_tag(source, options={})
        input_tag(:image, options.reverse_merge(:src => image_path(source)))
      end

      ##
      # Constructs a hidden field containing a CSRF token.
      #
      # @param [String] token
      #   The token to use. Will be read from the session by default.
      #
      # @return [String] The hidden field with CSRF token as value.
      #
      # @example
      #   csrf_token_field
      #
      def csrf_token_field(token = nil)
        hidden_field_tag csrf_param, :value => csrf_token
      end

      ##
      # Constructs meta tags `csrf-param` and `csrf-token` with the name of the
      # cross-site request forgery protection parameter and token, respectively.
      #
      # @return [String] The meta tags with the CSRF token and the param your app expects it in.
      #
      # @example
      #   csrf_meta_tags
      #
      def csrf_meta_tags
        if is_protected_from_csrf?
          meta_tag(csrf_param, :name => 'csrf-param') <<
          meta_tag(csrf_token, :name => 'csrf-token')
        end
      end

      ##
      # Creates a form containing a single button that submits to the URL.
      #
      # @overload button_to(name, url, options={})
      #   @param [String]  caption  The text caption.
      #   @param [String]  url      The url href.
      #   @param [Hash]    options  The html options.
      # @overload button_to(name, options={}, &block)
      #   @param [String]  url      The url href.
      #   @param [Hash]    options  The html options.
      #   @param [Proc]    block    The button content.
      #
      # @option options [Boolean] :multipart
      #   If true, this form will support multipart encoding.
      # @option options [String] :remote
      #   Instructs ujs handler to handle the submit as ajax.
      # @option options [Symbol] :method
      #   Instructs ujs handler to use different http method (i.e :post, :delete).
      # @option options [Hash] :submit_options
      #   Hash of any options, that you want to pass to submit_tag (i.e :id, :class)
      #
      # @return [String] Form and button html with specified +options+.
      #
      # @example
      #   button_to 'Delete', url(:accounts_destroy, :id => account), :method => :delete, :class => :form
      #   # Generates:
      #   # <form class="form" action="/admin/accounts/destroy/2" method="post">
      #   #   <input type="hidden" value="delete" name="_method" />
      #   #   <input type="submit" value="Delete" />
      #   # </form>
      #
      def button_to(*args, &block)
        options   = args.extract_options!.dup
        name, url = args[0], args[1]
        options['data-remote'] = 'true' if options.delete(:remote)
        submit_options = options.delete(:submit_options) || {}
        if block_given?
          form_tag(url || name, options, &block)
        else
          form_tag(url, options) do
            submit_tag(name, submit_options)
          end
        end
      end

      ##
      # Constructs a range tag from the given options.
      #
      # @example
      #   range_field_tag('ranger_with_min_max', :min => 1, :max => 50)
      #   range_field_tag('ranger_with_range', :range => 1..5)
      #
      # @param [String] name
      #   The name of the range field.
      # @param [Hash] options
      #   The html options for the range field.
      # @option options [Integer] :min
      #  The min range of the range field.
      # @option options [Integer] :max
      #  The max range of the range field.
      # @option options [range] :range
      #  The range, in lieu of :min and :max.  See examples for details.
      # @return [String] The html range field
      #
      def range_field_tag(name, options = {})
        options = options.reverse_merge(:name => name)
        if range = options.delete(:range)
          options[:min], options[:max] = range.min, range.max
        end
        input_tag(:range, options)
      end

      protected

      ##
      # Returns an array of option items for a select field based on the given collection.
      #
      # @param [Array] fields
      #   fields is an array containing the fields to display from each item in the collection.
      #
      def options_from_collection(collection, fields)
        collection.map { |item| [ item.send(fields.first), item.send(fields.last) ] }
      end

      ##
      # Returns the options tags for a select based on the given option items.
      #
      def options_for_select(option_items, state = {})
        return [] if option_items.blank?
        option_items.map do |caption, value, attributes|
          html_attributes = { :value => value || caption  }.merge(attributes||{})
          html_attributes[:selected] ||= option_is_selected?(value, caption, state[:selected])
          html_attributes[:disabled] ||= option_is_selected?(value, caption, state[:disabled])
          content_tag(:option, caption, html_attributes)
        end
      end

      ##
      # Returns the optgroups with options tags for a select based on the given :grouped_options items.
      #
      def grouped_options_for_select(collection, state = {})
        collection.map do |item|
          caption = item.shift
          attributes = item.last.kind_of?(Hash) ? item.pop : {}
          value = item.flatten(1)
          attributes = value.pop if value.last.kind_of?(Hash)
          html_attributes = { :label => caption }.merge(attributes||{})
          content_tag(:optgroup, options_for_select(value, state), html_attributes)
        end
      end

      ##
      # Returns the blank option serving as a prompt if passed.
      #
      def blank_option(prompt)
        case prompt
        when nil, false
          nil
        when String
          content_tag(:option, prompt,       :value => '')
        when Array
          content_tag(:option, prompt.first, :value => prompt.last)
        else
          content_tag(:option, '',           :value => '')
        end
      end

      ##
      # Returns whether the application is being protected from CSRF. Defaults to true.
      #
      def is_protected_from_csrf?
        defined?(settings) ? settings.protect_from_csrf : true
      end

      ##
      # Returns the current CSRF token (based on the session). If it doesn't exist,
      # it will create one and assign it to the session's `csrf` key.
      #
      def csrf_token
        session[:csrf] ||= SecureRandom.hex(32) if defined?(session)
      end

      ##
      # Returns the param/field name in which your CSRF token should be expected by your
      # controllers. Defaults to `authenticity_token`.
      #
      # Set this in your application with `set :csrf_param, :something_else`.
      #
      def csrf_param
        defined?(settings) && settings.respond_to?(:csrf_param) ?
          settings.csrf_param : :authenticity_token
      end

      private

      ##
      # Returns the FormBuilder class to use based on all available setting sources
      # If explicitly defined, returns that, otherwise returns defaults.
      #
      # @example
      #   configured_form_builder_class(nil) => StandardFormBuilder
      #
      def configured_form_builder_class(explicit_builder=nil)
        default_builder    = self.respond_to?(:settings) && self.settings.default_builder
        configured_builder = explicit_builder || default_builder || 'StandardFormBuilder'
        configured_builder = "Padrino::Helpers::FormBuilder::#{configured_builder}".constantize if configured_builder.is_a?(String)
        configured_builder
      end

      ##
      # Returns an initialized builder instance for the given object and settings.
      #
      # @example
      #   builder_instance(@account, :nested => { ... }) => <FormBuilder>
      #
      def builder_instance(object, settings={})
         builder_class = configured_form_builder_class(settings.delete(:builder))
         builder_class.new(self, object, settings)
      end

      ##
      # Returns whether the option should be selected or not.
      #
      # @example
      #   option_is_selected?("red", "Red", ["red", "blue"])   => true
      #   option_is_selected?("red", "Red", ["green", "blue"]) => false
      #
      def option_is_selected?(value, caption, selected_values)
        Array(selected_values).any? do |selected|
          [value.to_s, caption.to_s].include?(selected.to_s)
        end
      end

      def extract_option_state!(options)
        {
          :selected => Array(options.delete(:selected))|Array(options.delete(:selected_options)),
          :disabled => Array(options.delete(:disabled_options))
        }
      end

      def extract_option_tags!(options)
        state = extract_option_state!(options)
        option_tags = case
        when options[:options]
          options_for_select(options.delete(:options), state)
        when options[:grouped_options]
          grouped_options_for_select(options.delete(:grouped_options), state)
        else
          []
        end
        prompt = options.delete(:include_blank)
        option_tags.unshift(blank_option(prompt)) if prompt
        option_tags
      end

      def resolve_object(object)
        object.is_a?(Symbol) ? instance_variable_get("@#{object}") : object
      end
    end
  end
end
