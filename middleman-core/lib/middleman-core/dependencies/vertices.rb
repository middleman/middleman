require 'middleman-core/dependencies/vertices/data_collection_vertex'
require 'middleman-core/dependencies/vertices/data_collection_path_vertex'
require 'middleman-core/dependencies/vertices/file_vertex'

module Middleman
  module Dependencies
    VERTICES_BY_TYPE = {
      DataCollectionVertex::TYPE_ID => DataCollectionVertex,
      DataCollectionPathVertex::TYPE_ID => DataCollectionPathVertex,
      FileVertex::TYPE_ID => FileVertex
    }.freeze
  end
end
