page "a.html", :proxy => 'content.html', :ignore => true do
  @a = "set"
end

page "b.html", :proxy => 'content.html', :ignore => true do
  @b = "set"
end
