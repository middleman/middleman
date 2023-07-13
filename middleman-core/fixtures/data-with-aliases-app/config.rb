data.pages.each do |p|
  proxy p.from, p.to, locals: { content: p.content }
end
