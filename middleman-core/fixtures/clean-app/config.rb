page "/fake.html", :proxy => "/real.html", :layout => false

ignore "/should_be_ignored.html"
page "/should_be_ignored2.html", :ignore => true
page "/target_ignore.html", :proxy => "/should_be_ignored3.html", :ignore => true

%w(one two).each do |num|
  page "/fake/#{num}.html", :proxy => "/real/index.html" do
    @num = num
  end
end
