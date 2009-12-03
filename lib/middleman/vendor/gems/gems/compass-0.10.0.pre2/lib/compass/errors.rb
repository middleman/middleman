module Compass
  class Error < StandardError
  end

  class FilesystemConflict < Error
  end

  class MissingDependency < Error
  end
end
