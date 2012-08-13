data.pages.each do |p|
  page p.from, :proxy => p.to
end
