# frozen_string_literal: true

activate :external_pipeline,
         name: :assets,
         command: 'echo "Done"',
         source: 'tmp',
         latency: 2,
         manifest_json: File.expand_path('manifest.json', __dir__)
