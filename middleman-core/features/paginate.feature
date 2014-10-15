Feature: Pagination
  Scenario: Basic configuration
    Given a fixture app "paginate-app"
    And a file named "config.rb" with:
      """
      articles = resources.select { |r|
        matcher = ::Middleman::Util::UriTemplates.uri_template('blog/2011-{remaining}')
        ::Middleman::Util::UriTemplates.extract_params(matcher, ::Middleman::Util.normalize_path(r.url))
      }

      articles.sort { |a, b|
        b.data.date <=> a.data.date
      }.per_page(5) do |items, num, meta, is_last|
        page_path = num == 1 ? '/2011/index.html' : "/2011/page/#{num}.html"

        prev_page = case num
        when 1
          nil
        when 2
          '/2011/index.html'
        when 3
          "/2011/page/#{num-1}.html"
        end

        next_page = is_last ? nil : "/2011/page/#{num+1}.html"

        proxy page_path, "/archive/2011/index.html", locals: {
          items: items,
          pagination: meta,
          prev_page: prev_page,
          next_page: next_page
        }
      end

      def get_tags(resource)
        if resource.data.tags.is_a? String
          resource.data.tags.split(',').map(&:strip)
        else
          resource.data.tags
        end
      end

      def group_lookup(resource, sum)
        results = Array(get_tags(resource)).map(&:to_s).map(&:to_sym)

        results.each do |k|
          sum[k] ||= []
          sum[k] << resource
        end
      end

      tags = articles
          .select { |resource| resource.data.tags }
          .each_with_object({}, &method(:group_lookup))

      tags.each do |k, articles_in_tag|
        articles_in_tag.sort { |a, b|
          b.data.date <=> a.data.date
        }.per_page(2).each do |items, num, meta, is_last|
          page_path = num == 1 ? "/tags/#{k}.html" : "/tags/#{k}/page/#{num}.html"

          prev_page = case num
          when 1
            nil
          when 2
            "/tags/#{k}.html"
          when 3
            "/tags/#{k}/page/#{num-1}.html"
          end

          next_page = is_last ? nil : "/tags/#{k}/page/#{num+1}.html"

          proxy page_path, "/archive/2011/index.html", locals: {
            items: items,
            pagination: meta,
            prev_page: prev_page,
            next_page: next_page
          }
        end
      end
      """
    And the Server is running
    When I go to "/2011/index.html"
    Then I should see "Paginate: true"
    Then I should see "Article Count: 5"
    Then I should see "Page Num: 1"
    Then I should see "Num Pages: 2"
    Then I should see "Per Page: 5"
    Then I should see "Page Start: 1"
    Then I should see "Page End: 5"
    Then I should see "Next Page: '/2011/page/2.html'"
    Then I should see "Prev Page: ''"
    Then I should not see "/blog/2011-01-01-test-article.html"
    Then I should not see "/blog/2011-01-02-test-article.html"
    Then I should see "/blog/2011-01-03-test-article.html"
    Then I should see "/blog/2011-01-04-test-article.html"
    Then I should see "/blog/2011-01-05-test-article.html"
    Then I should see "/blog/2011-02-01-test-article.html"
    Then I should see "/blog/2011-02-02-test-article.html"

    When I go to "/2011/page/2.html"
    Then I should see "Article Count: 2"
    Then I should see "Page Num: 2"
    Then I should see "Page Start: 6"
    Then I should see "Page End: 7"
    Then I should see "Next Page: ''"
    Then I should see "Prev Page: '/2011/'"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should not see "/2011-01-03-test-article.html"
    Then I should not see "/2011-01-04-test-article.html"
    Then I should not see "/2011-01-05-test-article.html"
    Then I should not see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-02-test-article.html"

    When I go to "/tags/bar.html"
    Then I should see "Paginate: true"
    Then I should see "Article Count: 2"
    Then I should see "Page Num: 1"
    Then I should see "Num Pages: 3"
    Then I should see "Per Page: 2"
    Then I should see "Page Start: 1"
    Then I should see "Page End: 2"
    Then I should see "Next Page: '/tags/bar/page/2.html'"
    Then I should see "Prev Page: ''"
    Then I should see "/2011-02-02-test-article.html"
    Then I should see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-05-test-article.html"
    Then I should not see "/2011-01-04-test-article.html"
    Then I should not see "/2011-01-03-test-article.html"

  Scenario: Custom pager method
    Given a fixture app "paginate-app"
    And a file named "config.rb" with:
      """
      def items_per_page(all_items)
        [
          all_items.shift(2),
          all_items
        ]
      end

      articles = resources.select { |r|
        matcher = ::Middleman::Util::UriTemplates.uri_template('blog/2011-{remaining}')
        ::Middleman::Util::UriTemplates.extract_params(matcher, ::Middleman::Util.normalize_path(r.url))
      }

      articles.sort { |a, b|
        b.data.date <=> a.data.date
      }.per_page(method(:items_per_page).to_proc).each do |items, num, meta, is_last|
        page_path = num == 1 ? '/2011/index.html' : "/2011/page/#{num}.html"

        prev_page = case num
        when 1
          nil
        when 2
          '/2011/index.html'
        when 3
          "/2011/page/#{num-1}.html"
        end

        next_page = is_last ? nil : "/2011/page/#{num+1}.html"

        proxy page_path, "/archive/2011/index.html", locals: {
          items: items,
          pagination: meta,
          prev_page: prev_page,
          next_page: next_page
        }
      end
      """
    And the Server is running
    When I go to "/2011/index.html"
    Then I should see "Paginate: true"
    Then I should see "Article Count: 2"
    Then I should see "Page Num: 1"
    Then I should see "Num Pages: 2"
    Then I should see "Per Page: 2"
    Then I should see "Page Start: 1"
    Then I should see "Page End: 2"
    Then I should see "Next Page: '/2011/page/2.html'"
    Then I should see "Prev Page: ''"
    Then I should not see "/blog/2011-01-01-test-article.html"
    Then I should not see "/blog/2011-01-02-test-article.html"
    Then I should not see "/blog/2011-01-03-test-article.html"
    Then I should not see "/blog/2011-01-04-test-article.html"
    Then I should not see "/blog/2011-01-05-test-article.html"
    Then I should see "/blog/2011-02-01-test-article.html"
    Then I should see "/blog/2011-02-02-test-article.html"

    When I go to "/2011/page/2.html"
    Then I should see "Article Count: 5"
    Then I should see "Page Num: 2"
    Then I should see "Page Start: 3"
    Then I should see "Page End: 7"
    Then I should see "Next Page: ''"
    Then I should see "Prev Page: '/2011/'"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should see "/2011-01-03-test-article.html"
    Then I should see "/2011-01-04-test-article.html"
    Then I should see "/2011-01-05-test-article.html"
    Then I should not see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-02-test-article.html"
