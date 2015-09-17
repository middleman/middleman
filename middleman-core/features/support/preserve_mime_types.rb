Around('@preserve_mime_types') do |_scenario, block|
  mime_types = ::Rack::Mime::MIME_TYPES.clone

  block.call

  ::Rack::Mime::MIME_TYPES.replace mime_types
end
