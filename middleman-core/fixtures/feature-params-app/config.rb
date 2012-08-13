set :layout, false

module ExtensionA
  class << self
    def registered(app, options={})
      app.set :a_options, options
    end
    alias :included :registered
  end
end

activate ExtensionA, :hello => "world", :hola => "mundo"
