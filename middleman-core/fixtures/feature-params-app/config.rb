set :layout, false

class ExtensionA < ::Middleman::Extension
  helpers do
    def get_option(key)
      extensions[:extension_a].options[key]
    end
  end

  option :hello, '', ''
  option :hola, '', ''
end

Middleman::Extensions.register :extension_a, ExtensionA

activate :extension_a, hello: "world", hola: "mundo"
