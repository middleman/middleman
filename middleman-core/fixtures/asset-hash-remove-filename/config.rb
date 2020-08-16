# frozen_string_literal: true

activate :asset_hash,
         rename_proc: lambda do |path, _basename, digest, extension, _options|
           "#{path}#{digest}#{extension}"
         end

activate :relative_assets

activate :directory_indexes
