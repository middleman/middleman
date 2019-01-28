activate :asset_hash,
  rename_proc: -> (path, basename, digest, extension, options) {
    "#{path}#{digest}#{extension}"
  }

activate :relative_assets

activate :directory_indexes
