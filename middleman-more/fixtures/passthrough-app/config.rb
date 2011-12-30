module ::PassThrough
  def self.compress(data)
    data
  end
end

set :js_compressor, ::PassThrough
set :css_compressor, ::PassThrough

activate :minify_javascript
activate :minify_css

with_layout false do
  page "/inline-css.html"
  page "/inline-js.html"
  page "/inline-coffeescript.html"
end