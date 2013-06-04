module Padrino
  module Helpers
    class Breadcrumb

      attr_accessor :home
      attr_accessor :items

      DEFAULT_URL = "/"
      DEFAULT_CAPTION ="Home Page"

      ##
      # initialize breadcrumbs with default value
      #
      # @example
      #   before do
      #     @breadcrumbs = breadcrumbs.new
      #   end
      #
      # @api public
      def initialize
        self.home = { :url => DEFAULT_URL, :caption => DEFAULT_CAPTION, :name => :home }
        reset
      end

      ##
      # Set the custom home (Parent) link
      #
      # @param [String] url
      #  The url href
      #
      # @param [String] caption
      #   The  text caption.
      #
      # @example
      #   breadcrumbs.set_home "/HomeFoo", "Foo Home"
      #
      #
      # @api public
      def set_home(url, caption)
        self.home = { :url => url, :caption => caption.to_s.humanize.html_safe, :name => :home }
        reset
      end

      ##
      # Reset breadcrumbs to default or personal  home
      #
      # @example
      #   breadcrumbs.reset
      #
      # @api public
      def reset
        self.items=[]
        self.items << home
      end

      ##
      # Reset breadcrumbs to default home
      #
      # @example
      #   breadcrumbs.reset!
      #
      # @api public
      def reset!
        self.home = { :url => DEFAULT_URL, :caption => DEFAULT_CAPTION, :name => :home }
        reset
      end

      ##
      # Add a new  breadcrumbs
      #
      # @param [String] name
      #   The name of resource
      # @param [Symbol] name
      #   The name of resource
      #
      # @param [String] url
      #   The url href.
      #
      # @param [String] caption
      #   The text caption
      #
      # @example
      #   breadcrumbs.add "foo", "/foo", "Foo Link"
      #   breadcrumbs.add :foo, "/foo", "Foo Link"
      #
      # @api public
      def add(name, url, caption)
        items << { :name => name, :url => url.to_s, :caption => caption.to_s.humanize.html_safe }
      end

      alias :<< :add

      ##
      # Remove a Breadcrumbs
      #
      # @param [String] name
      #  The name of resource to delete from breadcrumbs list
      #
      # @param [Symbol] name
      #  The name of resource to delete from breadcrumbs list
      #
      # @example
      #   breadcrumbs.del "foo"
      #   breadcrumbs.del :foo
      #
      # @api public
      def del(name)
        items.delete_if { |item| item[:name] == name.to_sym }
      end

    end # Breadcrumb


    module Breadcrumbs

      # Render breadcrumbs to view
      #
      # @param [Breadcrumbs] breadcrumbs
      #   The breadcrumbs to render into view
      #
      # @param [Boolean] bootstrap
      #  If true, render separation (usefull with Twitter Bootstrap)
      #
      # @param [String] active
      #  Css class style set to active breadcrumb
      #
      # @return [String] Unordered list with breadcrumbs
      #
      # @example
      #  = breadcrumbs @breacrumbs
      #  # Generates:
      #  # <ul>
      #  #   <li><a herf="/foo" >Foo Link</a></li>
      #  #   <li class="active" ><a herf="/bar">Bar Link</a></li>
      #  # </ul>
      #
      #
      # @api public
      def breadcrumbs(breadcrumbs, bootstrap=false, active="active")
        content=""
        breadcrumbs.items[0..-2].each do |item|
          content << render_item(item, bootstrap)
        end
        last = link_to(breadcrumbs.items.last[:caption], breadcrumbs.items.last[:url])
        content << safe_content_tag(:li, last, :class => active)
        safe_content_tag(:ul, content, :class => "breadcrumb" )
      end

      private
      ##
      # Private method to return list item
      #
      # @param [Hash] item
      #   The breadcrumb item
      #
      # @param [Boolean] bootstrap
      #   If true, render separation (usefull with Twitter Bootstrap)
      #
      # @return [String] List item with breacrumb
      #
      # @api public
      def render_item(item, bootstrap)
        content = ""
        content << link_to(item[:caption], item[:url])
        content << safe_content_tag(:span, "/", :class => "divider") if bootstrap
        safe_content_tag(:li, content )
      end

    end # Breadcrumb
  end # Helpers
end # Padrino
