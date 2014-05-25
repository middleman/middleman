%w{
  /auto-css.html
  /auto-css
  /auto-css/
  /auto-css/auto-css.html
  /auto-css/sub/auto-css.html
}.each do |path|
  page path, layout: false
end
