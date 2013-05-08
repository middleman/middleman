with_layout false do
  %w{
    /auto-css.html
    /auto-css
    /auto-css/
    /auto-css/auto-css.html
    /auto-css/sub/auto-css.html
  }.each do |path|
    page path
  end
end
