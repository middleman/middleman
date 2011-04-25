module Middleman::Features::TinySrc
  class << self
    def registered(app)
      Middleman::Assets.register :tiny_src do |path, prefix, request|
        original_output = Middleman::Assets.before(:tiny_src, path, prefix, request)
        "http://i.tinysrc.mobi/#{original_output}"
      end
    end
    alias :included :registered
  end
end