# frozen_string_literal: true

data.pages.each do |p|
  proxy p.from, p.to
end
