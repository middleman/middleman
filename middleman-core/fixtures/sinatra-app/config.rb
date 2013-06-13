require "sinatra"

class MySinatra < Sinatra::Base
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
