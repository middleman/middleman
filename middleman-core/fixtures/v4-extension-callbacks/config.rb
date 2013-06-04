class ExtensionOne < ::Middleman::Extension
  def initialize(app, options_hash={})
    super

    after_extension_activated :extension_two do
      app.set :extension_two_was_activated, true
    end
  end
end

ExtensionOne.register

class ExtensionTwo < ::Middleman::Extension
  def initialize(app, options_hash={})
    super

    after_extension_activated :extension_one do
      app.set :extension_one_was_activated, true
    end
  end
end

ExtensionTwo.register

activate :extension_one
activate :extension_two