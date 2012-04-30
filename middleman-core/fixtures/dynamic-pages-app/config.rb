# -*- coding: utf-8 -*-
page "/fake.html", :proxy => "/real.html", :layout => false
page "fake2.html", :proxy => "/real.html", :layout => false
page "fake3.html", :proxy => "real.html", :layout => false
page "/fake4.html", :proxy => "real.html", :layout => false

ignore "/should_be_ignored.html"
page "/should_be_ignored2.html", :ignore => true
page "/target_ignore.html", :proxy => "/should_be_ignored3.html", :ignore => true

ignore "should_be_ignored4.html"
page "should_be_ignored5.html", :ignore => true
page "target_ignore2.html", :proxy => "/should_be_ignored6.html", :ignore => true
page "target_ignore3.html", :proxy => "should_be_ignored7.html", :ignore => true
page "/target_ignore4.html", :proxy => "should_be_ignored8.html", :ignore => true

%w(one two).each do |num|
  page "/fake/#{num}.html", :proxy => "/real/index.html", :ignore => true do
    @num = num
  end
  page "fake2/#{num}.html", :proxy => "/real/index.html", :ignore => true do
    @num = num
  end
  page "fake3/#{num}.html", :proxy => "real/index.html", :ignore => true do
    @num = num
  end
  page "/fake4/#{num}.html", :proxy => "real/index.html", :ignore => true do
    @num = num
  end
end

page "明日がある.html", :proxy => "/real.html", :layout => false

page "f*/*" do
  @all_glob = "I am all glob"
end

page "fake/*" do
  @glob_var = "I am one glob"
end

page "fake2/*" do
  @glob_var = "I am two glob"
end

page "fake3/*" do
  @glob_var = "I am three glob"
end

page "fake4/*" do
  @glob_var = "I am four glob"
end
