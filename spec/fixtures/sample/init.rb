# enable :maruku
get "/inline-js.html" do
  haml :"inline-js.html", :layout => false
end