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

ExtensionA.register

activate :extension_a, :hello => "world", :hola => "mundo"
