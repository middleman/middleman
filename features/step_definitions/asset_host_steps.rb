Given /^I am using an asset host$/ do
  @initialize_commands ||= []
  @initialize_commands << lambda { 
    activate :asset_host
    set :asset_host do |asset|
      "http://assets%d.example.com" % (asset.hash % 4)
    end
  }
end