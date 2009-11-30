require 'net/http'
require 'fileutils'
require 'rubygems'
require 'zip/zip'


def fetch(uri_str, limit = 10)
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)
  http = Net::HTTP.new(url.host, url.port)
  http.open_timeout = 2
  http.read_timeout = 30
  response = http.start do |http|
     puts "getting #{url.path}"
     http.request_get(url.path)
  end
  
  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end

def install_from_github(user, project, ext_name, branch = "master", working_directory = Dir.pwd)
  download_link = "http://github.com/#{user}/#{project}/zipball/#{branch}"
  extdir = File.join(working_directory,'extensions')
  
  if !File.exists?(extdir)
    begin
      puts "Downloading the #{ext_name} plugin into #{extdir}."
      FileUtils.mkdir(extdir)
      zipfile = File.join(extdir, "#{ext_name}.zip")
      open(zipfile, "wb") do |tgz|
        tgz << fetch(download_link).body
      end
      puts "Unzipping the #{ext_name} plugin."
      Zip::ZipFile::open(zipfile) { |zf|
         zf.each { |e|
           fpath = File.join(extdir, e.name)
           FileUtils.mkdir_p(File.dirname(fpath))
           zf.extract(e, fpath)
         }
      }
      File.unlink(zipfile)
      funky_directory = Dir.glob(File.join(extdir,"#{user}-#{project}-*"))[0]
      FileUtils.mv(funky_directory, File.join(extdir, ext_name))
      puts "#{ext_name} installed."
    rescue Exception => e
      FileUtils.rm_rf(extdir)
      raise
    end
  end

end
