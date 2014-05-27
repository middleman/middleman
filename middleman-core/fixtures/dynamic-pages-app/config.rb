# -*- coding: utf-8 -*-
page "/fake.html", proxy: "/real.html", layout: false
page "fake2.html", proxy: "/real.html", layout: false
page "fake3.html", proxy: "real.html", layout: false
page "/fake4.html", proxy: "real.html", layout: false

ignore "/should_be_ignored.html"
page "/should_be_ignored2.html", ignore: true
page "/target_ignore.html", proxy: "/should_be_ignored3.html", ignore: true

ignore "should_be_ignored4.html"
page "should_be_ignored5.html", ignore: true
page "target_ignore2.html", proxy: "/should_be_ignored6.html", ignore: true
page "target_ignore3.html", proxy: "should_be_ignored7.html", ignore: true
page "/target_ignore4.html", proxy: "should_be_ignored8.html", ignore: true

%w(one two).each do |num|
  page "/fake/#{num}.html", proxy: "/real/index.html", ignore: true, locals: { num: num }
  page "fake2/#{num}.html", proxy: "/real/index.html", ignore: true, locals: { num: num }
  page "fake3/#{num}.html", proxy: "real/index.html", ignore: true, locals: { num: num }
  page "/fake4/#{num}.html", proxy: "real/index.html", ignore: true, locals: { num: num }
end

page "明日がある.html", proxy: "/real.html", layout: false

page "f*/*", locals: { all_glob: "I am all glob" }
page "fake/*", locals: { glob_var: "I am one glob" }
page "fake2/*", locals: { glob_var: "I am two glob" }
page "fake3/*", locals: { glob_var: "I am three glob" }
page "fake4/*", locals: { glob_var: "I am four glob" }
