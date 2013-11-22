module Padrino
  module Helpers
    class Breadcrumb
      attr_accessor :home, :items

      DEFAULT_URL = "/"
      DEFAULT_CAPTION ="Home Page"

      ##
      # Initialize breadcrumbs with default value.
      #
      # @example
      #   before do
      #     @breadcrumbs = breadcrumbs.new
      #   end
      #
      def initialize
        reset!
      end

      ##
      # Set the custom home (Parent) link.
      #
      # @param [String] url
      #  The url href.
      #
      # @param [String] caption
      #   The  text caption.
      #
      # @param [Hash] options
      #   The HTML options to include in li.
      #
      # @example
      #   breadcrumbs.set_home "/HomeFoo", "Foo Home", :id => "home-breadcrumb"
      #
      def set_home(url, caption, options = {})
        self.home = {
          :url     => url.to_s,
          :caption => caption.to_s.humanize.html_safe,
          :name    => :home,
          :options => options
        }
        reset
      end

      ##
      # Reset breadcrumbs to default or personal home.
      #
      # @example
      #   breadcrumbs.reset
      #
      def reset
        self.items = []
        self.items << home
      end

      ##
      # Reset breadcrumbs to default home.
      #
      # @example
      #   breadcrumbs.reset!
      #
      def reset!
        self.home = {
          :name    => :home,
          :url     => DEFAULT_URL,
          :caption => DEFAULT_CAPTION,
          :options => {}
        }
        reset
      end

      ##
      # Add a new breadcrumbs.
      #
      # @param [String] name
      #   The name of resource.
      # @param [Symbol] name
      #   The name of resource.
      #
      # @param [String] url
      #   The url href.
      #
      # @param [String] caption
      #   The text caption.
      #
      # @param [Hash] options
      #   The HTML options to include in li.
      #
      # @example
      #   breadcrumbs.add "foo", "/foo", "Foo Link", :id => "foo-id"
      #   breadcrumbs.add :foo, "/foo", "Foo Link", :class => "foo-class"
      #
      def add(name, url, caption, options = {})
        items << {
          :name    => name.to_sym,
          :url     => url.to_s,
          :caption => caption.to_s.humanize.html_safe,
          :options => options
        }
      end
      alias :<< :add

      ##
      # Remove a breadcrumb.
      #
      # @param [String] name
      #  The name of resource to delete from breadcrumbs list.
      #
      # @example
      #   breadcrumbs.del "foo"
      #   breadcrumbs.del :foo
      #
      def del(name)
        items.delete_if { |item| item[:name] == name.to_sym }
      end
    end

    module Breadcrumbs
      ##
      # Render breadcrumbs to view.
      #
      # @param [Breadcrumbs] breadcrumbs
      #   The breadcrumbs to render into view.
      #
      # @param [Boolean] bootstrap
      #  If true, render separation (useful with Twitter Bootstrap).
      #
      # @param [String] active
      #  CSS class style set to active breadcrumb.
      #
      # @param [Hash] options
      #   The HTML options to include in ul.
      #
      # @return [String] Unordered list with breadcrumbs
      #
      # @example
      #  = breadcrumbs @breacrumbs
      #  # Generates:
      #  # <ul>
      #  #   <li><a href="/foo">Foo Link</a></li>
      #  #   <li class="active"><a href="/bar">Bar Link</a></li>
      #  # </ul>
      #
      def breadcrumbs(breadcrumbs, bootstrap = false, active = "active", options = {})
        content = ""
        breadcrumbs.items[0..-2].each do |item|
          content << render_item(item, bootstrap)
        end
        last = breadcrumbs.items.last
        last_options = last[:options]
        last = link_to(last[:caption], last[:url])

        classes = [options[:class], last_options[:class]].map { |class_name| class_name.to_s.split(/\s/) }
        classes[0] << "breadcrumb"
        classes[1] << active if active
        options[:class], last_options[:class] = classes.map { |class_name| class_name * " " }

        content << safe_content_tag(:li, last, last_options)
        safe_content_tag(:ul, content, options)
      end

      private
      ##
      # Private method to return list item.
      #
      # @param [Hash] item
      #   The breadcrumb item.
      #
      # @param [Boolean] bootstrap
      #   If true, render separation (useful with Twitter Bootstrap).
      #
      # @return [String] List item with breadcrumb
      #
      def render_item(item, bootstrap)
        content = ""
        content << link_to(item[:caption], item[:url])
        content << safe_content_tag(:span, "/", :class => "divider") if bootstrap
        safe_content_tag(:li, content, item[:options])
      end
    end
  end
end
