%w{
  /auto-js.html
  /auto-js
  /auto-js/
  /auto-js/auto-js.html
  /auto-js/sub/auto-js.html
}.each do |path|
  page path, layout: false
end
