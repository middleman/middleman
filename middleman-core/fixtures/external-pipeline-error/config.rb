activate :external_pipeline,
  name: :failing,
  command: "mv does-not-exist tmp/file.js",
  source: "tmp",
  latency: 2
