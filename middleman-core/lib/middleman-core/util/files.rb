module Middleman
  module Util
    include Contracts

    module_function

    # Get a recusive list of files inside a path.
    # Works with symlinks.
    #
    # @param path Some path string or Pathname
    # @param ignore A proc/block that returns true if a given path should be ignored - if a path
    #               is ignored, nothing below it will be searched either.
    # @return [Array<Pathname>] An array of Pathnames for each file (no directories)
    Contract Or[String, Pathname], Proc => ArrayOf[Pathname]
    def all_files_under(path, &ignore)
      path = Pathname(path)

      if ignore && yield(path)
        []
      elsif path.directory?
        path.children.flat_map do |child|
          all_files_under(child, &ignore)
        end.compact
      elsif path.file?
        [path]
      else
        []
      end
    end

    # Glob a directory and try to keep path encoding consistent.
    #
    # @param [String] path The glob path.
    # @return [Array<String>]
    def glob_directory(path)
      results = ::Dir[path]

      return results unless RUBY_PLATFORM =~ /darwin/

      results.map { |r| r.encode('UTF-8', 'UTF-8-MAC') }
    end

    # Get the PWD and try to keep path encoding consistent.
    #
    # @param [String] path The glob path.
    # @return [Array<String>]
    def current_directory
      result = ::Dir.pwd

      return result unless RUBY_PLATFORM =~ /darwin/

      result.encode('UTF-8', 'UTF-8-MAC')
    end

    Contract String => String
    def step_through_extensions(path)
      while ::Tilt[path]
        ext = ::File.extname(path)
        yield ext if block_given?

        # Strip templating extensions as long as Tilt knows them
        path = path[0..-(ext.length + 1)]
      end

      yield ::File.extname(path) if block_given?

      path
    end

    # Removes the templating extensions, while keeping the others
    # @param [String] path
    # @return [String]
    Contract String => String
    def remove_templating_extensions(path)
      step_through_extensions(path)
    end

    # Removes the templating extensions, while keeping the others
    # @param [String] path
    # @return [String]
    Contract String => ArrayOf[String]
    def collect_extensions(path)
      return [] if ::File.basename(path).start_with?('.')

      result = []

      step_through_extensions(path) { |e| result << e }

      result
    end

    # Finds files which should also be considered to be dirty when
    # the given file(s) are touched.
    #
    # @param [Middleman::Application] app The app.
    # @param [Pathname] files The original touched file paths.
    # @return [Middleman::SourceFile] All related file paths, not including the source file paths.
    Contract ::Middleman::Application, ArrayOf[Pathname] => ArrayOf[::Middleman::SourceFile]
    def find_related_files(app, files)
      return [] if files.empty?

      all_extensions = files.flat_map { |f| collect_extensions(f.to_s) }

      sass_type_aliasing = ['.scss', '.sass']
      erb_type_aliasing = ['.erb', '.haml', '.slim']

      if (all_extensions & sass_type_aliasing).length > 0
        all_extensions |= sass_type_aliasing
      end

      if (all_extensions & erb_type_aliasing).length > 0
        all_extensions |= erb_type_aliasing
      end

      all_extensions.uniq!

      app.sitemap.resources.select(&:file_descriptor).select { |r|
        local_extensions = collect_extensions(r.file_descriptor[:full_path].to_s)

        if (local_extensions & sass_type_aliasing).length > 0
          local_extensions |= sass_type_aliasing
        end

        if (local_extensions & erb_type_aliasing).length > 0
          local_extensions |= erb_type_aliasing
        end

        local_extensions.uniq!

        ((all_extensions & local_extensions).length > 0) && files.none? { |f| f == r.file_descriptor[:full_path] }
      }.map(&:file_descriptor)
    end
  end
end
