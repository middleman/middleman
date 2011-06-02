with_layout false do
  page "/inline-css.html"
  page "/inline-js.html"
  page "/inline-coffeescript.html"
  page "/slim.html"
end

get "/page-class.html" do
  haml :"page-classes.html", :layout => false
end

get "/sub1/page-class.html" do
  haml :"page-classes.html", :layout => false
end

get "/sub1/sub2/page-class.html" do
  haml :"page-classes.html", :layout => false
end

get "/auto-css.html" do
  haml :"auto-css.html", :layout => false
end

get "/sub1/auto-css.html" do
  haml :"auto-css.html", :layout => false
end

get "/sub1/sub2/auto-css.html" do
  haml :"auto-css.html", :layout => false
end
