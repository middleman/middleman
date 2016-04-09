class MyFeature < Middleman::Extension

  def manipulate_resource_list(resources)

    resources.each do |resource|

      # Contrived example: we're removing integer prefixes from file names
      # during output, e.g., rename_paths/30_item_three/10_sibling_one.html.md
      # becomes rename_paths/item_three/sibling_one.html

      if ( match = /(\d+?)_/.match(resource.path) )
        resource.destination_path = resource.destination_path.gsub(/(\d+?)_/, '') # fails!
        puts resource.destination_path
        # resource.destination_path.gsub!(/(\d+?)_/, '') # works!
      end

    end

  end

end

::Middleman::Extensions.register(:my_feature, MyFeature)

activate :my_feature


proxy "/sub/fake.html", "/proxied.html", ignore: true
proxy "/sub/fake2.html", "/proxied.html", ignore: true

proxy "/directory-indexed/fake.html", "/proxied.html", ignore: true
proxy "/directory-indexed/fake2.html", "/proxied.html", ignore: true
