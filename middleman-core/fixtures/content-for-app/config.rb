require "slim"

with_layout :content_for do
  page "/content_for_erb.html"
  page "/content_for_haml.html"
  page "/content_for_slim.html"
end
