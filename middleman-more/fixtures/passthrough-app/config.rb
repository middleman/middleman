module ::PassThrough
  def self.compress(data)
    data
  end
end

activate :minify_javascript
activate :minify_css

set :js_compressor, ::PassThrough
set :css_compressor, ::PassThrough

with_layout false do
  page "/inline-css.html"
  page "/inline-js.html"
  page "/inline-coffeescript.html"
end
