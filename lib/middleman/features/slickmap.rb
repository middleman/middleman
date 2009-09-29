require 'slickmap'

get '/sitemap.html' do
  haml :sitemap, :layout => false
end