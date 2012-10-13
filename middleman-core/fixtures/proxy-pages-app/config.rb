# -*- coding: utf-8 -*-
proxy "/fake.html", "/real.html", :layout => false
proxy "fake2.html", "/real.html", :layout => false
proxy "fake3.html", "real.html", :layout => false
proxy "/fake4.html", "real.html", :layout => false

proxy "/target_ignore.html", "/should_be_ignored3.html", :ignore => true
proxy "target_ignore2.html", "/should_be_ignored6.html", :ignore => true
proxy "target_ignore3.html", "should_be_ignored7.html", :ignore => true
proxy "/target_ignore4.html", "should_be_ignored8.html", :ignore => true

%w(one two).each do |num|
  proxy "/fake/#{num}.html", "/real/index.html", :ignore => true, :locals => { :num => num }
  proxy "fake2/#{num}.html", "/real/index.html", :ignore => true, :locals => { :num => num }
  proxy "fake3/#{num}.html", "real/index.html", :ignore => true, :locals => { :num => num }
  proxy "/fake4/#{num}.html", "real/index-ivars.html", :ignore => true do
    @num = num
  end
end

proxy "明日がある.html", "/real.html", :layout => false
