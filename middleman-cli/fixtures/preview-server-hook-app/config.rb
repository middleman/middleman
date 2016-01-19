set :layout, false

class MyFeature < Middleman::Extension
  def initialize(app, options_hash = {}, &block)
    super

    app.before_server do |server_information|
      puts "/// #{server_information.listeners.first} ///"
      puts "/// #{server_information.port} ///"
      puts "/// #{server_information.server_name} ///"
      puts "/// #{server_information.site_addresses.first} ///"
      puts "/// ### END ### ///"
    end
  end
end

::Middleman::Extensions.register(:my_feature, MyFeature)

activate :my_feature
