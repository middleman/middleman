require 'active_support/core_ext/object/deep_dup'
require 'middleman-core/util'

module Middleman
  module Pagination
    module ArrayHelpers
      def per_page(per_page)
        return to_enum(__method__, per_page) unless block_given?

        parts = if per_page.respond_to? :call
          per_page.call(dup)
        else
          each_slice(per_page).reduce([]) do |sum, items|
            sum << items
          end
        end

        num_pages = parts.length
        collection = self

        current_start_i = 0
        parts.each_with_index do |items, i|
          num = i + 1

          meta = ::Middleman::Pagination.page_locals(
            num,
            num_pages,
            collection,
            items,
            current_start_i
          )

          yield items, num, meta, num >= num_pages

          current_start_i += items.length
        end
      end
    end

    def self.page_locals(page_num, num_pages, collection, items, page_start)
      per_page = items.length

      # Index into collection of the last item of this page
      page_end = (page_start + per_page) - 1

      ::Middleman::Util.recursively_enhance(page_number: page_num,
                                            num_pages: num_pages,
                                            per_page: per_page,

                                            # The range of item numbers on this page
                                            # (1-based, for showing "Items X to Y of Z")
                                            page_start: page_start + 1,
                                            page_end: [page_end + 1, collection.length].min,

                                            # Use "collection" in templates.
                                            collection: collection)
    end
  end
end
