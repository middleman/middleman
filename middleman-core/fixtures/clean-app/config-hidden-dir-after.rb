set :build_dir, ".build"

ignore "/should_be_ignored.html"
page "/should_be_ignored2.html", :ignore => true
page "/target_ignore.html", :proxy => "/should_be_ignored3.html", :ignore => true
