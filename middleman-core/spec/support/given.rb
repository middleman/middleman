module Given
  ROOT = File.expand_path( '../..', File.dirname( File.realpath(__FILE__) ) )
  TMP  = File.join( ROOT, 'tmp' )

  class << self

    def fixture name
      cleanup!

      `rsync -av #{File.join( ROOT, 'fixtures', name )}/ #{TMP}/`
      Dir.chdir TMP
      ENV['MM_ROOT'] = TMP
    end

    def no_file name
      FileUtils.rm name, force: true
    end

    def symlink source, destination
      no_file destination
      FileUtils.symlink File.expand_path(source),
                        File.expand_path(destination),
                        force: true
    end

    def file name, content
      file_path = File.join( TMP, name )
      FileUtils.mkdir_p( File.dirname(file_path) )
      File.open( file_path, 'w' ) do |file|
        file.write content
      end
    end

    def cleanup!
      Dir.chdir ROOT
      if File.exist? TMP
        `rm -rf #{TMP}`
      end
    end

  end
end
