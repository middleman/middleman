# -*- coding: utf-8 -*-
proxy "/fake.html", "/real.html", layout: false
proxy "fake2.html", "/real.html", layout: false
proxy "fake3.html", "real.html", layout: false
proxy "/fake4.html", "real.html", layout: false

ignore "/should_be_ignored.html"
ignore "/should_be_ignored2.html"
proxy "/target_ignore.html", "/should_be_ignored3.html", ignore: true

ignore "should_be_ignored4.html"
ignore "should_be_ignored5.html"
proxy "target_ignore2.html", "/should_be_ignored6.html", ignore: true
proxy "target_ignore3.html", "should_be_ignored7.html", ignore: true
proxy "/target_ignore4.html", "should_be_ignored8.html", ignore: true

%w(one two).each do |num|
  proxy "/fake/#{num}.html", "/real/index.html", ignore: true, locals: { num: num }
  proxy "fake2/#{num}.html", "/real/index.html", ignore: true, locals: { num: num }
  proxy "fake3/#{num}.html", "real/index.html", ignore: true, locals: { num: num }
  proxy "/fake4/#{num}.html", "real/index.html", ignore: true, locals: { num: num }
end

proxy "明日がある.html", "/real.html", layout: false

page "f*/*", locals: { all_glob: "I am all glob" }
page "fake/*", locals: { glob_var: "I am one glob" }
page "fake2/*", locals: { glob_var: "I am two glob" }
page "fake3/*", locals: { glob_var: "I am three glob" }
page "fake4/*", locals: { glob_var: "I am four glob" }

["tom", "dick", "harry"].each do |name|
  proxy "/about/#{name}.html", "/should_be_ignored9.html", locals: { person_name: name }, ignore: true
end
