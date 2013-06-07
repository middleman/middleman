require "slim"

with_layout :capture_html do
  page "/capture_html_erb.html"
  page "/capture_html_haml.html"
  page "/capture_html_slim.html"
end
