module SDoc::GitHub
  def github_url(path)
    unless @github_url_cache.has_key? path
      @github_url_cache[path] = false
      file = RDoc::TopLevel.find_file_named(path)
      if file
        base_url = repository_url(path)
        if base_url
          sha1 = commit_sha1(path)
          if sha1
            relative_url = path_relative_to_repository(path)
            @github_url_cache[path] = "#{base_url}#{sha1}#{relative_url}"
          end
        end
      end
    end
    @github_url_cache[path]
  end
  
  protected
  
  def commit_sha1(path)
    name = File.basename(path)
    s = in_dir(File.join(basedir, File.dirname(path))) do
      `git log -1 --pretty=format:"commit %H" #{name}`
    end
    m = s.match(/commit\s+(\S+)/)
    m ? m[1] : false
  end
  
  def repository_url(path)
    s = in_dir(File.join(basedir, File.dirname(path))) do
      `git config --get remote.origin.url`
    end
    m = s.match(%r{github.com[/:](.*)\.git$})
    m ? "http://github.com/#{m[1]}/blob/" : false
  end

  def path_relative_to_repository(path)
    absolute_path = File.join(basedir, path)
    root = path_to_git_dir(File.dirname(absolute_path))
    absolute_path[root.size..absolute_path.size]
  end

  def path_to_git_dir(path)
    while !path.empty? && path != '.'
      if (File.exists? File.join(path, '.git')) 
        return path
      end
      path = File.dirname(path)
    end
    ''
  end  
  
  def in_dir(dir)
    pwd = Dir.pwd
    Dir.chdir dir
    return yield
  rescue Exception => e
    return ''
  ensure
    Dir.chdir pwd
  end
end
