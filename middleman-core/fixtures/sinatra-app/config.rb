require "sinatra"

class MySinatra < Sinatra::Base
  set :host_authorization, { permitted_hosts: "www.example.com" }

  get "/" do
    "Hello World (Sinatra)"
  end
  get "/derp.html" do
    "De doo"
  end
end

map "/sinatra" do
  run MySinatra
end
