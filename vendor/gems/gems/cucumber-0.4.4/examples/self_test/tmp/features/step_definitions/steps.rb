Given /^a failing step$/ do
  raise "I fail"
end

Given /^a passing step$/ do
end

Given /^a pending step$/ do
  pending
end