module Compass
  module Configuration
    # Comments are emitted into the configuration file when serialized and make it easier to understand for new users.
    module Comments

      def comment_for_http_path
        "# Set this to the root of your project when deployed:\n"
      end

      def comment_for_relative_assets
        unless relative_assets
          %q{# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true
}
        else
          ""
        end
      end

    end
  end
end
