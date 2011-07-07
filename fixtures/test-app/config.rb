with_layout false do
  page "/inline-css.html"
  page "/inline-js.html"
  page "/inline-coffeescript.html"
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