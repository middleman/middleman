
activate :asset_hash,
         rename_proc: lambda { |path, _basename, digest, extension, _options|
           "#{path}#{digest}#{extension}"
         }

activate :relative_assets

activate :directory_indexes
