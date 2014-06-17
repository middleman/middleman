proxy "/fake.html", "/real.html", layout: false

ignore "/should_be_ignored.html"
ignore "/should_be_ignored2.html"
proxy "/target_ignore.html", "/should_be_ignored3.html", ignore: true

%w(one two).each do |num|
  proxy "/fake/#{num}.html", "/real/index.html", locals: { num: num }
end
