# frozen_string_literal: true

activate :external_pipeline,
         name: :assets,
         command: 'echo "Done"',
         source: 'tmp',
         latency: 2,
         manifest_json: File.expand_path('manifest.json', __dir__)

activate :external_pipeline,
         name: :different_pipeline,
         command: 'echo "Done"',
         source: 'tmp',
         latency: 2,
         manifest_json: File.expand_path('different_manifest.json', __dir__)
