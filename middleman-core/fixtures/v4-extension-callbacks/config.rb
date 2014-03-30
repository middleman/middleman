class ExtensionOne < ::Middleman::Extension
  helpers do
    def extension_two_was_activated
      extensions[:extension_one].extension_two_was_activated
    end
  end

  attr_reader :extension_two_was_activated

  def initialize(app, options_hash={})
    super

    after_extension_activated :extension_two do
      @extension_two_was_activated = true
    end
  end
end

Middleman::Extensions.register :extension_one, ExtensionOne

class ExtensionTwo < ::Middleman::Extension
  helpers do
    def extension_one_was_activated
      extensions[:extension_two].extension_one_was_activated
    end
  end

  attr_reader :extension_one_was_activated

  def initialize(app, options_hash={})
    super

    after_extension_activated :extension_one do
      @extension_one_was_activated = true
    end
  end
end

Middleman::Extensions.register :extension_two, ExtensionTwo

activate :extension_one
activate :extension_two
