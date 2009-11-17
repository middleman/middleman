class Gem::Commands::MigrateCommand < Gem::AbstractCommand
  attr_reader :rubygem

  def description
    'Migrate a gem your own from Rubyforge to Gemcutter.'
  end

  def initialize
    super 'migrate', description
  end

  def execute
    setup
    migrate
  end

  def migrate
    find(get_one_gem_name)
    token = get_token
    upload_token(token)
    check_for_approved
  end

  def project_name
    rubygem['rubyforge_project'] || rubygem['name']
  end

  def find(name)
    require 'json/pure'

    response = make_request(:get, "gems/#{name}.json")

    case response
    when Net::HTTPSuccess
      begin
        @rubygem = JSON.parse(response.body)
      rescue JSON::ParserError => json_error
        say "There was a problem parsing the data: #{json_error}"
        terminate_interaction
      end
    else
      say "This gem is currently not hosted on Gemcutter."
      terminate_interaction
    end
  end

  def get_token
    say "Starting migration of #{rubygem["name"]} from RubyForge..."

    response = make_request(:post, "gems/#{rubygem["name"]}/migrate") do |request|
      request.add_field("Content-Length", 0)
      request.add_field("Authorization", api_key)
    end

    case response
    when Net::HTTPSuccess
      say "A migration token has been created."
      response.body
    else
      say response.body
      terminate_interaction
    end
  end

  def upload_token(token)
    require 'tempfile'
    require 'net/scp'

    url = "#{project_name}.rubyforge.org"
    say "Uploading the migration token to #{url}."

    rf_cfg_path = "#{Gem.user_home}/.rubyforge/user-config.yml"

    login, password = if File.exists?(rf_cfg_path)
      rcfg = YAML.load_file(rf_cfg_path)
      rcfg.values_at('username', 'password')
    else
      say "Please enter your RubyForge login:"
      [ask("Login: "), ask_for_password("Password: ")]
    end

    begin
      Net::SCP.start(url, login, :password => password) do |scp|
        temp_token = Tempfile.new("token")
        temp_token.chmod 0644
        temp_token.write(token)
        temp_token.close
        scp.upload! temp_token.path, "/var/www/gforge-projects/#{project_name}/migrate-#{rubygem['name']}.html"
      end
      say "Successfully uploaded your token."
    rescue Exception => e
      say "There was a problem uploading your token: #{e}"
    end
  end

  def check_for_approved
    say "Asking Gemcutter to verify the upload..."

    response = make_request(:put, "gems/#{rubygem["name"]}/migrate") do |request|
      request.add_field("Content-Length", 0)
      request.add_field("Authorization", api_key)
    end

    say response.body
  end
end
