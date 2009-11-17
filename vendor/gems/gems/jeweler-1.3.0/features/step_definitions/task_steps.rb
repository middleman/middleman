Then /^I can gem install "([^"]+)"$/ do |gem_path|
  @stdout = `cd #{@working_dir}; gem install --install-dir #{@working_dir}/gem-install-dir --no-ri --no-rdoc #{gem_path} 2>&1`
  assert_no_match /ERROR/, @stdout
  assert $?.exited?
end

