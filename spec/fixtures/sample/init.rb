# enable :maruku
get "/inline-js.html" do
  haml :"inline-js.html", :layout => false
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