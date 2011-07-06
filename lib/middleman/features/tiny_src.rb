module Middleman::Features::TinySrc
  class << self
    def registered(app)
      app.register_asset_handler :tiny_src do |path, prefix, request|
        original_output = app.before_asset_handler(:tiny_src, path, prefix, request)
        "http://i.tinysrc.mobi/#{original_output}"
      end
    end
    alias :included :registered
  end
end