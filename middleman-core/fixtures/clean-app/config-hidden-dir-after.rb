set :build_dir, ".build"

ignore "/should_be_ignored.html"
ignore "/should_be_ignored2.html"
proxy "/target_ignore.html", "/should_be_ignored3.html", ignore: true
