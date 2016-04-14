Feature: Collections
  Scenario: Lazy query
    Given a fixture app "collections-app"
    And a file named "config.rb" with:
      """
      articles1 = collection :articles1, resources.select { |r|
        matcher = ::Middleman::Util::UriTemplates.uri_template('blog1/{year}-{month}-{day}-{title}.html')
        ::Middleman::Util::UriTemplates.extract_params(matcher, ::Middleman::Util.normalize_path(r.url))
      }

      everything = resources.select do |r|
        true
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

      tags = everything
          .select { |resource| resource.data.tags }
          .each_with_object({}, &method(:group_lookup))

      class Wrapper
        attr_reader :stuff

        def initialize
          @stuff = Set.new
        end

        def <<((k, v))
          @stuff << k
          self
        end
      end

      collection :wrapped, tags.reduce(Wrapper.new, :<<)

      set :tags, tags # Expose to templates

      collection :first_tag, tags.keys.sort.first
      """
    And a file named "source/index.html.erb" with:
      """
      <% collection(:articles1).each do |article| %>
        Article1: <%= article.data.title %>
      <% end %>

      Tag Count: <%= collection(:wrapped).stuff.length %>

      <% config[:tags].value.each do |k, items| %>
        Tag: <%= k %> (<%= items.length %>)
        <% items.each do |article| %>
          Article (<%= k %>): <%= article.data.title %>
        <% end %>
      <% end %>

      First Tag: <%= collection(:first_tag) %>
      """
    Given the Server is running at "collections-app"
    When I go to "index.html"
    Then I should see 'Article1: Blog1 Newer Article'
    And I should see 'Article1: Blog1 Another Article'
    And I should see 'Tag: foo (4)'
    And I should see 'Article (foo): Blog1 Newer Article'
    And I should see 'Article (foo): Blog1 Another Article'
    And I should see 'Article (foo): Blog2 Newer Article'
    And I should see 'Article (foo): Blog2 Another Article'
    And I should see 'Tag: bar (2)'
    And I should see 'Article (bar): Blog1 Newer Article'
    And I should see 'Article (bar): Blog2 Newer Article'
    And I should see 'Tag: 120 (1)'
    And I should see 'Article (120): Blog1 Another Article'
    And I should see 'First Tag: 120'
    And I should see 'Tag Count: 3'

  Scenario: Collected resources update with file changes
    Given a fixture app "collections-app"
    And a file named "config.rb" with:
      """
      collection :articles, resources.select { |r|
        matcher = ::Middleman::Util::UriTemplates.uri_template('blog2/{year}-{month}-{day}-{title}.html')
        ::Middleman::Util::UriTemplates.extract_params(matcher, ::Middleman::Util.normalize_path(r.url))
      }
      """
    And a file named "source/index.html.erb" with:
      """
      <% collection(:articles).each do |article| %>
        Article: <%= article.data.title || article.file_descriptor[:relative_path] %>
      <% end %>
      """
    Given the Server is running at "collections-app"
    When I go to "index.html"
    Then I should not see "Article: index.html.erb"
    Then I should see 'Article: Blog2 Newer Article'
    And I should see 'Article: Blog2 Another Article'

    And the file "source/blog2/2011-01-02-another-article.html.markdown" has the contents
      """
      ---
      title: "Blog3 Another Article"
      date: 2011-01-02
      tags:
        - foo
      ---

      Another Article Content

      """
    When I go to "index.html"
    Then I should see "Article: Blog2 Newer Article"
    And I should not see "Article: Blog2 Another Article"
    And I should see 'Article: Blog3 Another Article'

    And the file "source/blog2/2011-01-01-new-article.html.markdown" is removed
    When I go to "index.html"
    Then I should not see "Article: Blog2 Newer Article"
    And I should see 'Article: Blog3 Another Article'

    And the file "source/blog2/2014-01-02-yet-another-article.html.markdown" has the contents
      """
      ---
      title: "Blog2 Yet Another Article"
      date: 2011-01-02
      tags:
        - foo
      ---

      Yet Another Article Content
      """
    When I go to "index.html"
    And I should see 'Article: Blog3 Another Article'
    And I should see 'Article: Blog2 Yet Another Article'

  Scenario: Work with local helpers
    Given a fixture app "collections-app"
    And a file named "config.rb" with:
      """
      module TestHelper
        def help_me
          "ok"
        end
      end

      include TestHelper

      data.articles.each_with_index do |a, i|
        proxy "/#{i}-#{help_me}.html", a
      end
      """
    And a file named "data/articles.yaml" with:
      """
      ---
      - "/blog1/2011-01-01-new-article.html"
      - "/blog2/2011-01-02-another-article.html"
      """
    Given the Server is running at "collections-app"
    When I go to "0-ok.html"
    Then I should see 'Newer Article Content'
    When I go to "1-ok.html"
    Then I should see 'Another Article Content'

  Scenario: Collected data update with file changes
    Given a fixture app "collections-app"
    And a file named "config.rb" with:
      """
      data.articles.each_with_index do |a, i|
        proxy "/#{i}.html", a
      end
      """
    And a file named "data/articles.yaml" with:
      """
      ---
      - "/blog1/2011-01-01-new-article.html"
      - "/blog2/2011-01-02-another-article.html"
      """
    Given the Server is running at "collections-app"
    When I go to "0.html"
    Then I should see 'Newer Article Content'
    When I go to "1.html"
    Then I should see 'Another Article Content'
    When I go to "2.html"
    Then I should see 'Not Found'

    When the file "data/articles.yaml" has the contents
      """
      ---
      - "/blog1/2011-01-01-new-article.html"
      """
    When I go to "0.html"
    Then I should see 'Newer Article Content'
    When I go to "1.html"
    Then I should see 'Not Found'
    When I go to "2.html"
    Then I should see 'Not Found'

    When the file "data/articles.yaml" has the contents
      """
      ---
      - "/blog2/2011-01-02-another-article.html"
      - "/blog1/2011-01-01-new-article.html"
      - "/blog2/2011-01-01-new-article.html"
      """
    When I go to "0.html"
    Then I should see 'Another Article Content'
    When I go to "1.html"
    Then I should see 'Newer Article Content'
    When I go to "2.html"
    Then I should see 'Again'

  Scenario: Arbitrary live datasets
    Given a fixture app "collections-app"
    And a file named "config.rb" with:
      """
      ignore "/description_template.html"

      live {
        Dir[File.join(root, "descriptions/*.txt")]
      }.each do |description_name|
        base = File.basename(description_name, '.txt')
        proxy "#{base}.html", "/description_template.html", locals: {
          contents: File.read(description_name)
        }
      end
      """
    And a file named "source/description_template.html.erb" with:
      """
      <%= contents %>
      """
    And a file named "descriptions/test1.txt" with:
      """
      Test1
      """
    Given the Server is running at "collections-app"
    When I go to "test1.html"
    Then I should see 'Test1'
    When I go to "test2.html"
    Then I should see 'Not Found'

    When the file "descriptions/test2.txt" has the contents
      """
      Test2
      """
    When I go to "test1.html"
    Then I should see 'Test1'
    When I go to "test2.html"
    Then I should see 'Test2'

    When the file "descriptions/test1.txt" is removed
    When I go to "test1.html"
    Then I should see 'Not Found'
    When I go to "test2.html"
    Then I should see 'Test2'
