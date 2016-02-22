%w(1 2 3).each do |n|
  proxy "/#{n}.html", "/index.html", id: "page#{n}"
end

page "/overwrites/*", id: :"something-else"
