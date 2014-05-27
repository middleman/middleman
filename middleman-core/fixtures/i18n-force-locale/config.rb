[:en, :es].each do |locale|
  proxy "/#{locale}/index.html", "index.html", ignore: true, lang: locale
end

proxy "/fr/index.html", "index.html", lang: :fr

activate :i18n

# This is what breaks i18n, just because it adds a resource list manipulator that 
# forces a rebuild of the resource list.
activate :asset_hash
