module Padrino
  module Helpers
    module AssetTagHelpers
      ##
      # Creates a div to display the flash of given type if it exists
      #
      # ==== Examples
      #   # Generates: <div class="notice">flash-notice</div>
      #   flash_tag(:notice, :id => 'flash-notice')
      #
      def flash_tag(kind, options={})
        flash_text = flash[kind]
        return '' if flash_text.blank?
        options.reverse_merge!(:class => kind)
        content_tag(:div, flash_text, options)
      end

      ##
      # Creates a link element with given name, url and options
      #
      # ==== Examples
      #
      #   link_to('click me', '/dashboard', :class => 'linky')
      #   link_to('click me', '/dashboard', :remote => true)
      #   link_to('click me', '/dashboard', :method => :delete)
      #   link_to('click me', :class => 'blocky') do ... end
      #
      # Note that you can pass :+if+ or :+unless+ conditions, but if you provide :current as
      # condition padrino return true/false if the request.path_info match the given url
      #
      def link_to(*args, &block)
        options = args.extract_options!
        options = parse_js_attributes(options) # parses remote, method and confirm options
        anchor  = "##{CGI.escape options.delete(:anchor).to_s}" if options[:anchor]

        if block_given?
          url = args[0] ? args[0] + anchor.to_s : anchor || 'javascript:void(0);'
          options.reverse_merge!(:href => url)
          link_content = capture_html(&block)
          return '' unless parse_conditions(url, options)
          result_link = content_tag(:a, link_content, options)
          block_is_template?(block) ? concat_content(result_link) : result_link
        else
          name, url = args[0], (args[1] ? args[1] + anchor.to_s : anchor || 'javascript:void(0);')
          return name unless parse_conditions(url, options)
          options.reverse_merge!(:href => url)
          content_tag(:a, name, options)
        end
      end

      ##
      # Creates a form containing a single button that submits to the url.
      #
      # ==== Examples
      #
      #   # Generates:
      #   # <form class="form" action="/admin/accounts/destroy/2" method="post">
      #   #   <input type="hidden" value="delete" name="_method" />
      #   #   <input type="submit" value="Delete" />
      #   # </form>
      #   button_to 'Delete', url(:accounts_destroy, :id => account), :method => :delete, :class => :form
      #
      def button_to(*args, &block)
        name, url = args[0], args[1]
        options   = args.extract_options!
        desired_method = options[:method]
        options.delete(:method) if options[:method].to_s !~ /get|post/i
        options.reverse_merge!(:method => 'post', :action => url)
        options[:enctype] = "multipart/form-data" if options.delete(:multipart)
        options["data-remote"] = "true" if options.delete(:remote)
        inner_form_html  = hidden_form_method_field(desired_method)
        inner_form_html += block_given? ? capture_html(&block) : submit_tag(name)
        content_tag('form', inner_form_html, options)
      end

      ##
      # Creates a link tag that browsers and news readers can use to auto-detect an RSS or ATOM feed.
      #
      # === Options
      #
      #   :rel::   Specify the relation of this link, defaults to "alternate"
      #   :type::  Override the auto-generated mime type
      #   :title:: Specify the title of the link, defaults to the type
      #
      # === Examples
      #
      #   # Generates: <link type="application/atom+xml" rel="alternate" href="/blog/posts.atom" title="ATOM" />
      #   feed_tag :atom, url(:blog, :posts, :format => :atom), :title => "ATOM"
      #   # Generates: <link type="application/rss+xml" rel="alternate" href="/blog/posts.rss" title="rss" />
      #   feed_tag :rss, url(:blog, :posts, :format => :rss)
      #
      def feed_tag(mime, url, options={})
        full_mime = (mime == :atom) ? 'application/atom+xml' : 'application/rss+xml'
        content_tag(:link, options.reverse_merge(:rel => 'alternate', :type => full_mime, :title => mime, :href => url))
      end

      ##
      # Creates a mail link element with given name and caption
      #
      # ==== Examples
      #
      #   # Generates: <a href="mailto:me@demo.com">me@demo.com</a>
      #   mail_to "me@demo.com"
      #   # Generates: <a href="mailto:me@demo.com">My Email</a>
      #   mail_to "me@demo.com", "My Email"
      #
      def mail_to(email, caption=nil, mail_options={})
        html_options = mail_options.slice!(:cc, :bcc, :subject, :body)
        mail_query = Rack::Utils.build_query(mail_options).gsub(/\+/, '%20').gsub('%40', '@')
        mail_href = "mailto:#{email}"; mail_href << "?#{mail_query}" if mail_query.present?
        link_to((caption || email), mail_href, html_options)
      end

      ##
      # Creates a meta element with the content and given options
      #
      # ==== Examples
      #
      #   # Generates: <meta name="keywords" content="weblog,news">
      #   meta_tag "weblog,news", :name => "keywords"
      #
      #   # Generates: <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      #   meta_tag "text/html; charset=UTF-8", 'http-equiv' => "Content-Type"
      #
      def meta_tag(content, options={})
        options.reverse_merge!("content" => content)
        tag(:meta, options)
      end

      ##
      # Generates a favicon link. looks inside images folder
      #
      # ==== Examples
      #
      #   favicon_tag 'favicon.png'
      #   favicon_tag 'icons/favicon.png'
      #   # or override some options
      #   favicon_tag 'favicon.png', :type => 'image/ico'
      #
      def favicon_tag(source,options={})
        type = File.extname(source).gsub('.','')
        options = options.dup.reverse_merge!(:href => image_path(source), :rel => 'icon', :type => "image/#{type}")
        tag(:link, options)
      end

      ##
      # Creates an image element with given url and options
      #
      # ==== Examples
      #
      #   image_tag('icons/avatar.png')
      #
      def image_tag(url, options={})
        options.reverse_merge!(:src => image_path(url))
        tag(:img, options)
      end

      ##
      # Returns an html script tag for each of the sources provided.
      # You can pass in the filename without extension or a symbol and we search it in your +appname.public+
      # like app/public/stylesheets for inclusion. You can provide also a full path.
      #
      # ==== Examples
      #
      #   stylesheet_link_tag 'style', 'application', 'layout'
      #
      def stylesheet_link_tag(*sources)
        options = sources.extract_options!.symbolize_keys
        options.reverse_merge!(:media => 'screen', :rel => 'stylesheet', :type => 'text/css')
        sources.flatten.map { |source|
          tag(:link, options.reverse_merge(:href => asset_path(:css, source)))
        }.join("\n")
      end

      ##
      # Returns an html script tag for each of the sources provided.
      # You can pass in the filename without extension or a symbol and we search it in your +appname.public+
      # like app/public/javascript for inclusion. You can provide also a full path.
      #
      # ==== Examples
      #
      #   javascript_include_tag 'application', :extjs
      #
      def javascript_include_tag(*sources)
        options = sources.extract_options!.symbolize_keys
        options.reverse_merge!(:type => 'text/javascript', :content => "")
        sources.flatten.map { |source|
          tag(:script, options.reverse_merge(:src => asset_path(:js, source)))
        }.join("\n")
      end

      ##
      # Returns the path to the image, either relative or absolute. We search it in your +appname.public+
      # like app/public/images for inclusion. You can provide also a full path.
      #
      # ==== Examples
      #
      #   # Generates: /images/foo.jpg?1269008689
      #   image_path("foo.jpg")
      #
      def image_path(src)
        asset_path(:images, src)
      end

      ##
      # Returns the path to the specified asset (css or javascript)
      #
      # ==== Examples
      #
      #   # Generates: /javascripts/application.js?1269008689
      #   asset_path :js, :application
      #
      #   # Generates: /stylesheets/application.css?1269008689
      #   asset_path :css, :application
      #
      #   # Generates: /images/example.jpg?1269008689
      #   asset_path :images, 'example.jpg'
      #
      def asset_path(kind, source)
        return source if source =~ /^http/
        asset_folder  = case kind
          when :css then 'stylesheets'
          when :js  then 'javascripts'
          else kind.to_s
        end
        source = source.to_s.gsub(/\s/, '%20')
        ignore_extension = (asset_folder.to_s == kind.to_s) # don't append extension
        source << ".#{kind}" unless ignore_extension or source =~ /\.#{kind}/
        result_path   = source if source =~ %r{^/} # absolute path
        result_path ||= uri_root_path(asset_folder, source)
        timestamp = asset_timestamp(result_path)
        "#{result_path}#{timestamp}"
      end

      private

        ##
        # Returns the uri root of the application.
        #
        def uri_root_path(*paths)
          root_uri = self.class.uri_root if self.class.respond_to?(:uri_root)
          File.join(ENV['RACK_BASE_URI'].to_s, root_uri || '/', *paths)
        end

        ##
        # Returns the timestamp mtime for an asset
        #
        def asset_timestamp(file_path)
          return nil if file_path =~ /\?/ || (self.class.respond_to?(:asset_stamp) && !self.class.asset_stamp)
          public_path = Padrino.root("public", file_path) if Padrino.respond_to?(:root)
          stamp = Time.now.to_i unless public_path && File.exist?(public_path)
          stamp ||= File.mtime(public_path).to_i
          "?#{stamp}"
        end

        ##
        # Parses link_to options for given correct conditions
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

        ##
        # Parses link_to options for given js declarations (remote, method, confirm)
        # Not destructive on options; returns updated options
        #
        def parse_js_attributes(options)
          options = options.dup
          options["data-remote"] = "true" if options.delete(:remote)
          if link_confirm = options.delete(:confirm)
            options["data-confirm"] = link_confirm
          end
          if link_method = options.delete(:method)
            options["data-method"] = link_method
            options["rel"] = "nofollow"
          end
          options
        end
    end # AssetTagHelpers
  end # Helpers
end # Padrino