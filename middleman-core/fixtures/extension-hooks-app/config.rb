set :layout, false

class MyFeature < Middleman::Extension
  def initialize(app, options_hash = {}, &block)
    super

    app.before do
      puts '/// before ///'
    end

    app.ready do
      puts '/// ready ///'
    end

    app.before_render do |body, path, locs, template_class|
      puts "/// before_render ///"
    end

    app.after_render do |content, path, locs, template_class|
      puts "/// after_render ///"
    end

    app.before_build do |builder|
      puts "/// before_build ///"
    end

    app.after_build do |builder|
      puts "/// after_build ///"
    end
  end

  def after_configuration
    puts '/// after_configuration ///'
  end
end

::Middleman::Extensions.register(:my_feature, MyFeature)

activate :my_feature
