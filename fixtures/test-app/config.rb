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

%w{
	/auto-css.html
	/auto-css
	/auto-css/
	/auto-css/auto-css.html
	/auto-css/sub/auto-css.html
}.each do |path|
	get path do
		haml :"auto-css.html", :layout => false
	end
end

%w{
	/auto-js.html
	/auto-js
	/auto-js/
	/auto-js/auto-js.html
	/auto-js/sub/auto-js.html
}.each do |path|
	get path do
		haml :"auto-js.html", :layout => false
	end
end

