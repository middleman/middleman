class Gem::Commands::OwnerCommand < Gem::AbstractCommand
  def description
    'Manage gem owners on Gemcutter.'
  end

  def initialize
    super 'owner', description
    defaults.merge!(:add => [], :remove => [])

    add_option('-a', '--add EMAIL', 'Add an owner') do |value, options|
      options[:add] << value
    end

    add_option('-r', '--remove EMAIL', 'Remove an owner') do |value, options|
      options[:remove] << value
    end
  end

  def execute
    setup
    name = get_one_gem_name

    add_owners    name, options[:add]
    remove_owners name, options[:remove]
    show_owners   name
  end

  def add_owners(name, owners)
    owners.each do |owner|
      response = make_request(:post, "gems/#{name}/owners.json") do |request|
        request.set_form_data(:email => owner)
        request.add_field("Authorization", api_key)
      end
      
      case response
      when Net::HTTPSuccess
        say "Added owner: #{owner}"
      else
        say "Error adding owner: #{owner}"
      end
    end
  end

  def remove_owners(name, owners)
    owners.each do |owner|
      response = make_request(:delete, "gems/#{name}/owners.json") do |request|
        request.set_form_data(:email => owner)
        request.add_field("Authorization", api_key)
      end
      
      case response
      when Net::HTTPSuccess
        say "Removed owner: #{owner}"
      else
        say "Error removing owner: #{owner}"
      end
    end  end

  def show_owners(name)
    require 'json/pure'
    response = make_request(:get, "gems/#{name}/owners.json") do |request|
      request.add_field("Authorization", api_key)
    end

    case response
    when Net::HTTPSuccess
      begin
        owners = JSON.parse(response.body)

        say "Owners for gem: #{name}"
        owners.each do |owner|
          say "- #{owner['email']}"
        end
      rescue JSON::ParserError => json_error
        say "There was a problem parsing the data: #{json_error}"
        terminate_interaction
      end
    when Net::HTTPNotFound
      say "This gem is currently not hosted on Gemcutter."
      terminate_interaction
    when Net::HTTPUnauthorized
      say "You do not have permission to manage this gem."
      terminate_interaction
    else
      say "There was a problem processing your request."
      terminate_interaction
    end
  end
end
