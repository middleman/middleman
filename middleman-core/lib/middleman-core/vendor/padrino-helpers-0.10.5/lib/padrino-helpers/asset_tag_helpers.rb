module Padrino
  module Helpers
    ###
    # Helpers related to producing assets (images,stylesheets,js,etc) within templates.
    #
    module AssetTagHelpers
      ##
      # Creates a div to display the flash of given type if it exists
      #
      # @param [Symbol] kind
      #   The type of flash to display in the tag.
      # @param [Hash] options
      #   The html options for this section.
      #
      # @return [String] Flash tag html with specified +options+.
      #
      # @example
      #   flash_tag(:notice, :id => 'flash-notice')
      #   # Generates: <div class="notice">flash-notice</div>
      #   flash_tag(:error, :success)
      #   # Generates: <div class="error">flash-error</div>
      #   # <div class="success">flash-success</div>
      #
      # @api public
      def flash_tag(*args)
        options = args.extract_options!
        args.map do |kind|
          flash_text = flash[kind]
          next if flash_text.blank?
          content_tag(:div, flash_text, options.reverse_merge(:class => kind))
        end.compact * "\n"
      end

      ##
      # Creates a link element with given name, url and options
      #
      # @overload link_to(caption, url, options={})
      #   @param [String]  caption  The text caption.
      #   @param [String]  url      The url href.
      #   @param [Hash]    options  The html options.
      # @overload link_to(url, options={}, &block)
      #   @param [String]  url      The url href.
      #   @param [Hash]    options  The html options.
      #   @param [Proc]    block    The link content.
      #
      # @option options [String] :anchor
      #   The anchor for the link (i.e #something)
      # @option options [Boolean] :if
      #   If true, the link will appear, otherwise not;
      # @option options [Boolean] :unless
      #   If false, the link will appear, otherwise not;
      # @option options [Boolean] :remote
      #   If true, this link should be handled by a ajax ujs handler.
      # @option options [String] :confirm
      #   Instructs ujs handler to alert confirm message.
      # @option options [Symbol] :method
      #   Instructs ujs handler to use different http method (i.e :post, :delete).
      #
      # @return [String] Link tag html with specified +options+.
      #
      # @example
      #   link_to('click me', '/dashboard', :class => 'linky')
      #   link_to('click me', '/dashboard', :remote => true)
      #   link_to('click me', '/dashboard', :method => :delete)
      #   link_to('click me', :class => 'blocky') do; end
      #
      # Note that you can pass :+if+ or :+unless+ conditions, but if you provide :current as
      # condition padrino return true/false if the request.path_info match the given url
      #
      # @api public
      def link_to(*args, &block)
        options = args.extract_options!
        anchor  = "##{CGI.escape options.delete(:anchor).to_s}" if options[:anchor]

        if block_given?
          url = args[0] ? args[0] + anchor.to_s : anchor || '#'
          options.reverse_merge!(:href => url)
          link_content = capture_html(&block)
          return '' unless parse_conditions(url, options)
          result_link = content_tag(:a, link_content, options)
          block_is_template?(block) ? concat_content(result_link) : result_link
        else
          name, url = args[0], (args[1] ? args[1] + anchor.to_s : anchor || '#')
          return name unless parse_conditions(url, options)
          options.reverse_merge!(:href => url)
          content_tag(:a, name, options)
        end
      end

      ##
      # Creates a form containing a single button that submits to the url.
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
      # @api public
      def button_to(*args, &block)
        name, url = args[0], args[1]
        options   = args.extract_options!
        desired_method = options[:method]
        options.delete(:method) if options[:method].to_s !~ /get|post/i
        options.reverse_merge!(:method => 'post', :action => url)
        options[:enctype] = 'multipart/form-data' if options.delete(:multipart)
        options['data-remote'] = 'true' if options.delete(:remote)
        inner_form_html  = hidden_form_method_field(desired_method)
        inner_form_html += block_given? ? capture_html(&block) : submit_tag(name)
        content_tag('form', inner_form_html, options)
      end

      ##
      # Creates a link tag that browsers and news readers can use to auto-detect an RSS or ATOM feed.
      #
      # @param [Symbol] mime
      #   The mime type of the feed (i.e :atom or :rss).
      # @param [String] url
      #   The url for the feed tag to reference.
      # @param[Hash] options
      #   The options for the feed tag.
      # @option options [String] :rel ("alternate")
      #   Specify the relation of this link
      # @option options [String] :type
      #   Override the auto-generated mime type
      # @option options [String] :title
      #   Specify the title of the link, defaults to the type
      #
      # @return [String] Feed link html tag with specified +options+.
      #
      # @example
      #   feed_tag :atom, url(:blog, :posts, :format => :atom), :title => "ATOM"
      #   # Generates: <link type="application/atom+xml" rel="alternate" href="/blog/posts.atom" title="ATOM" />
      #   feed_tag :rss, url(:blog, :posts, :format => :rss)
      #   # Generates: <link type="application/rss+xml" rel="alternate" href="/blog/posts.rss" title="rss" />
      #
      # @api public
      def feed_tag(mime, url, options={})
        full_mime = (mime == :atom) ? 'application/atom+xml' : 'application/rss+xml'
        tag(:link, options.reverse_merge(:rel => 'alternate', :type => full_mime, :title => mime, :href => url))
      end

      ##
      # Creates a mail link element with given name and caption.
      #
      # @param [String] email
      #   The email address for the link.
      # @param [String] caption
      #   The caption for the link.
      # @param [Hash] mail_options
      #   The options for the mail link. Accepts html options.
      # @option mail_options [String] cc      The cc recipients.
      # @option mail_options [String] bcc     The bcc recipients.
      # @option mail_options [String] subject The subject line.
      # @option mail_options [String] body    The email body.
      #
      # @return [String] Mail link html tag with specified +options+.
      #
      # @example
      #   # Generates: <a href="mailto:me@demo.com">me@demo.com</a>
      #   mail_to "me@demo.com"
      #   # Generates: <a href="mailto:me@demo.com">My Email</a>
      #   mail_to "me@demo.com", "My Email"
      #
      # @api public
      def mail_to(email, caption=nil, mail_options={})
        html_options = mail_options.slice!(:cc, :bcc, :subject, :body)
        mail_query = Rack::Utils.build_query(mail_options).gsub(/\+/, '%20').gsub('%40', '@')
        mail_href = "mailto:#{email}"; mail_href << "?#{mail_query}" if mail_query.present?
        link_to((caption || email), mail_href, html_options)
      end

      ##
      # Creates a meta element with the content and given options.
      #
      # @param [String] content
      #   The content for the meta tag.
      # @param [Hash] options
      #   The html options for the meta tag.
      #
      # @return [String] Meta html tag with specified +options+.
      #
      # @example
      #   # Generates: <meta name="keywords" content="weblog,news">
      #   meta_tag "weblog,news", :name => "keywords"
      #
      #   # Generates: <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      #   meta_tag "text/html; charset=UTF-8", 'http-equiv' => "Content-Type"
      #
      # @api public
      def meta_tag(content, options={})
        options.reverse_merge!("content" => content)
        tag(:meta, options)
      end

      ##
      # Generates a favicon link. looks inside images folder
      #
      # @param [String] source
      #   The source image path for the favicon link tag.
      # @param [Hash] options
      #   The html options for the favicon link tag.
      #
      # @return [String] The favicon link html tag with specified +options+.
      #
      # @example
      #   favicon_tag 'favicon.png'
      #   favicon_tag 'icons/favicon.png'
      #   # or override some options
      #   favicon_tag 'favicon.png', :type => 'image/ico'
      #
      # @api public
      def favicon_tag(source, options={})
        type = File.extname(source).gsub('.','')
        options = options.dup.reverse_merge!(:href => image_path(source), :rel => 'icon', :type => "image/#{type}")
        tag(:link, options)
      end

      ##
      # Creates an image element with given url and options
      #
      # @param [String] url
      #   The source path for the image tag.
      # @param [Hash] options
      #   The html options for the image tag.
      #
      # @return [String] Image html tag with +url+ and specified +options+.
      #
      # @example
      #   image_tag('icons/avatar.png')
      #
      # @api public
      def image_tag(url, options={})
        options.reverse_merge!(:src => image_path(url))
        tag(:img, options)
      end

      ##
      # Returns an html script tag for each of the sources provided.
      # You can pass in the filename without extension or a symbol and we search it in your +appname.public_folder+
      # like app/public/stylesheets for inclusion. You can provide also a full path.
      #
      # @overload stylesheet_link_tag(*sources, options={})
      #   @param [Array<String>] sources   Splat of css source paths
      #   @param [Hash]          options   The html options for the link tag
      #
      # @return [String] Stylesheet link html tag for +sources+ with specified +options+.
      #
      # @example
      #   stylesheet_link_tag 'style', 'application', 'layout'
      #
      # @api public
      def stylesheet_link_tag(*sources)
        options = sources.extract_options!.symbolize_keys
        options.reverse_merge!(:media => 'screen', :rel => 'stylesheet', :type => 'text/css')
        sources.flatten.map { |source|
          tag(:link, options.reverse_merge(:href => asset_path(:css, source)))
        }.join("\n")
      end

      ##
      # Returns an html script tag for each of the sources provided.
      # You can pass in the filename without extension or a symbol and we search it in your +appname.public_folder+
      # like app/public/javascript for inclusion. You can provide also a full path.
      #
      # @overload javascript_include_tag(*sources, options={})
      #   @param [Array<String>] sources   Splat of js source paths
      #   @param [Hash]          options   The html options for the script tag
      #
      # @return [String] Script tag for +sources+ with specified +options+.
      #
      # @example
      #   javascript_include_tag 'application', :extjs
      #
      # @api public
      def javascript_include_tag(*sources)
        options = sources.extract_options!.symbolize_keys
        options.reverse_merge!(:type => 'text/javascript')
        sources.flatten.map { |source|
          content_tag(:script, nil, options.reverse_merge(:src => asset_path(:js, source)))
        }.join("\n")
      end

      ##
      # Returns the path to the image, either relative or absolute. We search it in your +appname.public_folder+
      # like app/public/images for inclusion. You can provide also a full path.
      #
      # @param [String] src
      #   The path to the image file (relative or absolute)
      #
      # @return [String] Path to an image given the +kind+ and +source+.
      #
      # @example
      #   # Generates: /images/foo.jpg?1269008689
      #   image_path("foo.jpg")
      #
      # @api public
      def image_path(src)
        asset_path(:images, src)
      end

      ##
      # Returns the path to the specified asset (css or javascript)
      #
      # @param [String] kind
      #   The kind of asset (i.e :images, :js, :css)
      # @param [String] source
      #   The path to the asset (relative or absolute).
      #
      # @return [String] Path for the asset given the +kind+ and +source+.
      #
      # @example
      #   # Generates: /javascripts/application.js?1269008689
      #   asset_path :js, :application
      #
      #   # Generates: /stylesheets/application.css?1269008689
      #   asset_path :css, :application
      #
      #   # Generates: /images/example.jpg?1269008689
      #   asset_path :images, 'example.jpg'
      #
      # @api semipublic
      def asset_path(kind, source)
        return source if source =~ /^http/
        is_absolute  = source =~ %r{^/}
        asset_folder = asset_folder_name(kind)
        source = source.to_s.gsub(/\s/, '%20')
        ignore_extension = (asset_folder.to_s == kind.to_s) # don't append an extension
        source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
        result_path = is_absolute ? source : uri_root_path(asset_folder, source)
        timestamp = asset_timestamp(result_path, is_absolute)
        "#{result_path}#{timestamp}"
      end

      private
      ##
      # Returns the uri root of the application with optional paths appended.
      #
      # @example
      #   uri_root_path("/some/path") => "/root/some/path"
      #   uri_root_path("javascripts", "test.js") => "/uri/root/javascripts/test.js"
      #
      def uri_root_path(*paths)
        root_uri = self.class.uri_root if self.class.respond_to?(:uri_root)
        File.join(ENV['RACK_BASE_URI'].to_s, root_uri || '/', *paths)
      end

      ##
      # Returns the timestamp mtime for an asset
      #
      # @example
      #   asset_timestamp("some/path/to/file.png") => "?154543678"
      #   asset_timestamp("/some/absolute/path.png", true) => nil
      #
      def asset_timestamp(file_path, absolute=false)
        return nil if file_path =~ /\?/ || (self.class.respond_to?(:asset_stamp) && !self.class.asset_stamp)
        public_file_path = Padrino.root("public", file_path) if Padrino.respond_to?(:root)
        stamp = File.mtime(public_file_path).to_i if public_file_path && File.exist?(public_file_path)
        stamp ||= Time.now.to_i unless absolute
        "?#{stamp}" if stamp
      end

      ###
      # Returns the asset folder given a kind.
      #
      # @example
      #   asset_folder_name(:css) => 'stylesheets'
      #   asset_folder_name(:js)  => 'javascripts'
      #   asset_folder_name(:images) => 'images'
      #
      def asset_folder_name(kind)
        case kind
        when :css then 'stylesheets'
        when :js  then 'javascripts'
        else kind.to_s
        end
      end

      ##
      # Parses link_to options for given correct conditions
      #
      # @example
      #   parse_conditions("/some/url", :if => false) => true
      #
      def parse_conditions(url, options)
        if options.has_key?(:if)
          condition = options.delete(:if)
          condition == :current ? url == request.path_info : condition
        elsif condition = options.delete(:unless)
          condition == :current ? url != request.path_info : !condition
        else
          true
        end
      end
    end # AssetTagHelpers
  end # Helpers
end # Padrino
