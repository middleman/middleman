require 'set'

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
      while ::Middleman::Util.tilt_class(path)
        ext = ::File.extname(path)
        break if ext.empty?

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
      @@extensions_cache ||= {}

      base_name = ::File.basename(path)
      @@extensions_cache[base_name] ||= begin
        result = []

        unless base_name.start_with?('.')
          step_through_extensions(base_name) { |e| result << e }
        end

        result
      end
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

      file_set = ::Set.new(files)

      all_extensions = files.flat_map { |f| collect_extensions(f.to_s) }
      sass_type_aliasing = ['.scss', '.sass']
      erb_type_aliasing = ['.erb', '.haml', '.slim']

      all_extensions |= sass_type_aliasing unless (all_extensions & sass_type_aliasing).empty?
      all_extensions |= erb_type_aliasing unless (all_extensions & erb_type_aliasing).empty?

      all_extensions.uniq!

      app.sitemap.resources.select { |r|
        if r.file_descriptor
          local_extensions = collect_extensions(r.file_descriptor[:full_path].to_s)
          local_extensions |= sass_type_aliasing unless (local_extensions & sass_type_aliasing).empty?
          local_extensions |= erb_type_aliasing unless (local_extensions & erb_type_aliasing).empty?

          local_extensions.uniq!

          !(all_extensions & local_extensions).empty? && !file_set.include?(r.file_descriptor[:full_path])
        else
          false
        end
      }.map(&:file_descriptor)
    end
  end
end
