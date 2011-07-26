xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Blog Name"
  xml.subtitle "Blog subtitle"
  xml.id "http://blog.url.com/"
  xml.link "href" => "http://blog.url.com/"
  xml.link "href" => "http://blog.url.com/feed.xml", "rel" => "self"
  xml.updated data.blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Blog Author" }

  data.blog.articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => article.url
      xml.id article.url
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Article Author" }
      xml.summary article.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end