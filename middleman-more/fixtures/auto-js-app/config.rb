with_layout false do
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
