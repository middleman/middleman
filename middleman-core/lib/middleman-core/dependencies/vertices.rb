require 'middleman-core/dependencies/vertices/file_vertex'

module Middleman
  module Dependencies
    VERTICES_BY_TYPE = {
      FileVertex::TYPE_ID => FileVertex
    }.freeze
  end
end
