class Middleman::Extensions::Pipeline < Middleman::Extension
  expose_to_config :pipeline

  def initialize(app, options_hash={}, &block)
    super
    @pipelines = []
  end

  def pipeline(&block)
    @pipelines << block
  end

  def manipulate_resource_list(resources)
    @pipelines.each do |pipeline|
      pipeline.call resources
    end
    resources
  end
end
