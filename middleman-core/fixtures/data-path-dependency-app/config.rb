data.people.each do |p|
  proxy "/#{p.slug}.html", '/person.html', ignore: true, locals: { person: p }
end
