page "/fake.html", :proxy => "/real.html", :layout => false

ignore "/should_be_ignored.html"
page "/should_be_ignored2.html", :ignore => true
page "/target_ignore.html", :proxy => "/should_be_ignored3.html", :ignore => true

%w(one two).each do |num|
  page "/fake/#{num}.html", :proxy => "/real/index.html" do
    @num = num
  end
end

with_layout false do
  page "/relative_image.html"
  page "/inline-css.html"
  page "/inline-js.html"
  page "/inline-coffeescript.html"
  page "/spaces in file.html"
  page "/slim.html"
  page "/data.html"
  page "/page-classes.html"
  page "/sub1/page-classes.html"
  page "/sub1/sub2/page-classes.html"

  %w{
    /auto-css.html
    /auto-css
    /auto-css/
    /auto-css/auto-css.html
    /auto-css/sub/auto-css.html
  }.each do |path|
    page path
  end

  %w{
    /auto-js.html
    /auto-js
    /auto-js/
    /auto-js/auto-js.html
    /auto-js/sub/auto-js.html
  }.each do |path|
    page path
  end
end

get "/sinatra_test" do
  "Ratpack"
end