require 'rubygems'
gem "rdoc", ">= 2.4.2"
if Gem.available? "json" 
  gem "json", ">= 1.1.3"
else
  gem "json_pure", ">= 1.1.3"
end

require 'iconv'
require 'json'
require 'pathname'
require 'fileutils'
require 'erb'

require 'rdoc/rdoc'
require 'rdoc/generator'
require 'rdoc/generator/markup'

require 'sdoc/github'
require 'sdoc/templatable'
require 'sdoc/helpers'

class RDoc::ClassModule
  def document_self_or_methods
    document_self || method_list.any?{ |m| m.document_self }
  end
  
  def with_documentation?
    document_self_or_methods || classes_and_modules.any?{ |c| c.with_documentation? }
  end
end

class RDoc::Generator::SHtml
  RDoc::RDoc.add_generator( self )
  include ERB::Util
  include SDoc::GitHub
  include SDoc::Templatable
  include SDoc::Helpers
  
  GENERATOR_DIRS = [File.join('sdoc', 'generator'), File.join('rdoc', 'generator')]
  
  # Used in js to reduce index sizes
  TYPE_CLASS  = 1
  TYPE_METHOD = 2
  TYPE_FILE   = 3
  
  TREE_FILE = File.join 'panel', 'tree.js'
  SEARCH_INDEX_FILE = File.join 'panel', 'search_index.js'
  
  FILE_DIR = 'files'
  CLASS_DIR = 'classes'
  
  RESOURCES_DIR = File.join('resources', '.')
  
  attr_reader :basedir
  
  def self.for(options)
    self.new(options)
  end
  
  def self.template_dir template
		$LOAD_PATH.map do |path|
		  GENERATOR_DIRS.map do |dir|
  			File.join path, dir, 'template', template
	    end
		end.flatten.find do |dir|
			File.directory? dir
		end
  end
  
  def initialize(options)
		@options = options
		@options.diagram = false
    @github_url_cache = {}
    
		template = @options.template || 'direct'

		templ_dir = self.class.template_dir template

		raise RDoc::Error, "could not find template #{template.inspect}" unless
			templ_dir
		
		@template_dir = Pathname.new File.expand_path(templ_dir)
		@basedir = Pathname.pwd.expand_path
  end
  
  def generate( top_levels )
		@outputdir = Pathname.new( @options.op_dir ).expand_path( @basedir )
		@files = top_levels.sort
		@classes = RDoc::TopLevel.all_classes_and_modules.sort

		# Now actually write the output
    copy_resources
    generate_class_tree
    generate_search_index
		generate_file_files
		generate_class_files
		generate_index_file
  end
  
	def class_dir
		CLASS_DIR
	end

	def file_dir
		FILE_DIR
	end

  
  protected
	### Output progress information if debugging is enabled
	def debug_msg( *msg )
		return unless $DEBUG_RDOC
		$stderr.puts( *msg )
	end  
  
  ### Create class tree structure and write it as json
  def generate_class_tree
    debug_msg "Generating class tree"
    topclasses = @classes.select {|klass| !(RDoc::ClassModule === klass.parent) } 
    tree = generate_file_tree + generate_class_tree_level(topclasses)
    debug_msg "  writing class tree to %s" % TREE_FILE
    File.open(TREE_FILE, "w", 0644) do |f|
      f.write('var tree = '); f.write(tree.to_json)
    end unless $dryrun
  end
  
  ### Recursivly build class tree structure
  def generate_class_tree_level(classes)
    tree = []
    classes.select{|c| c.with_documentation? }.sort.each do |klass|
      item = [
        klass.name, 
        klass.document_self_or_methods ? klass.path : '',
        klass.module? ? '' : (klass.superclass ? " < #{String === klass.superclass ? klass.superclass : klass.superclass.full_name}" : ''), 
        generate_class_tree_level(klass.classes_and_modules)
      ]
      tree << item
    end
    tree
  end
  
  ### Create search index for all classes, methods and files
  ### Wite it as json
  def generate_search_index
    debug_msg "Generating search index"
    
    index = {
      :searchIndex => [],
      :longSearchIndex => [],
      :info => []
    }
    
    add_class_search_index(index)
    add_method_search_index(index)
    add_file_search_index(index)
    
    debug_msg "  writing search index to %s" % SEARCH_INDEX_FILE
    data = {
      :index => index
    }
    File.open(SEARCH_INDEX_FILE, "w", 0644) do |f|
      f.write('var search_data = '); f.write(data.to_json)
    end unless $dryrun
  end
  
  ### Add files to search +index+ array
  def add_file_search_index(index)
    debug_msg "  generating file search index"
    
    @files.select { |file| 
      file.document_self 
    }.sort.each do |file|
      index[:searchIndex].push( search_string(file.name) )
      index[:longSearchIndex].push( search_string(file.path) )
      index[:info].push([
        file.name, 
        file.path, 
        file.path, 
        '', 
        snippet(file.comment),
        TYPE_FILE
      ])
    end
  end
  
  ### Add classes to search +index+ array
  def add_class_search_index(index)
    debug_msg "  generating class search index"
    
    @classes.select { |klass| 
      klass.document_self_or_methods
    }.sort.each do |klass|
      modulename = klass.module? ? '' : (klass.superclass ? (String === klass.superclass ? klass.superclass : klass.superclass.full_name) : '')
      index[:searchIndex].push( search_string(klass.name) )
      index[:longSearchIndex].push( search_string(klass.parent.full_name) )
      index[:info].push([
        klass.name, 
        klass.parent.full_name, 
        klass.path, 
        modulename ? " < #{modulename}" : '', 
        snippet(klass.comment),
        TYPE_CLASS
      ])
    end
  end
  
  ### Add methods to search +index+ array
  def add_method_search_index(index)
    debug_msg "  generating method search index"
    
    list = @classes.map { |klass| 
      klass.method_list
    }.flatten.sort{ |a, b| a.name == b.name ? a.parent.full_name <=> b.parent.full_name : a.name <=> b.name }.select { |method| 
      method.document_self 
    }
    unless @options.show_all
        list = list.find_all {|m| m.visibility == :public || m.visibility == :protected || m.force_documentation }
    end
    
    list.each do |method|
      index[:searchIndex].push( search_string(method.name) + '()' )
      index[:longSearchIndex].push( search_string(method.parent.full_name) )
      index[:info].push([
        method.name, 
        method.parent.full_name, 
        method.path, 
        method.params, 
        snippet(method.comment),
        TYPE_METHOD
      ])
    end
  end
  
	### Generate a documentation file for each class
	def generate_class_files
		debug_msg "Generating class documentation in #@outputdir"
    templatefile = @template_dir + 'class.rhtml'

		@classes.each do |klass|
			debug_msg "  working on %s (%s)" % [ klass.full_name, klass.path ]
			outfile     = @outputdir + klass.path
			rel_prefix  = @outputdir.relative_path_from( outfile.dirname )
      
			debug_msg "  rendering #{outfile}"
			self.render_template( templatefile, binding(), outfile )
		end
	end

	### Generate a documentation file for each file
	def generate_file_files
		debug_msg "Generating file documentation in #@outputdir"
    templatefile = @template_dir + 'file.rhtml'
    
		@files.each do |file|
			outfile     = @outputdir + file.path
			debug_msg "  working on %s (%s)" % [ file.full_name, outfile ]
			rel_prefix  = @outputdir.relative_path_from( outfile.dirname )

			debug_msg "  rendering #{outfile}"
			self.render_template( templatefile, binding(), outfile )
		end
	end
	
  def index_file
    if @options.main_page && file = @files.find { |f| f.full_name == @options.main_page }
      file
    else
      @files.first
    end
  end

	### Create index.html with frameset
	def generate_index_file
		debug_msg "Generating index file in #@outputdir"
    templatefile = @template_dir + 'index.rhtml'
    outfile      = @outputdir + 'index.html'
    index_path = index_file.path
	  
	  self.render_template( templatefile, binding(), outfile )
	end
	
	### Strip comments on a space after 100 chars
  def snippet(str)
    str ||= ''
    if str =~ /^(?>\s*)[^\#]/
      content = str
    else
      content = str.gsub(/^\s*(#+)\s*/, '')
    end
    
    content = content.sub(/^(.{100,}?)\s.*/m, "\\1").gsub(/\r?\n/m, ' ')
    
    begin
      content.to_json
    rescue # might fail on non-unicode string
      begin
        content = Iconv.conv('latin1//ignore', "UTF8", content) # remove all non-unicode chars
        content.to_json
      rescue
        content = '' # something hugely wrong happend
      end
    end
    content
  end

  ### Build search index key
  def search_string(string)
    string ||= ''
    string.downcase.gsub(/\s/,'')
  end
  
  ### Copy all the resource files to output dir
  def copy_resources
    resoureces_path = @template_dir + RESOURCES_DIR
		debug_msg "Copying #{resoureces_path}/** to #{@outputdir}/**"
    FileUtils.cp_r resoureces_path.to_s, @outputdir.to_s, :preserve => true unless $dryrun
  end

  class FilesTree
    attr_reader :children
    def add(path, url)
      path = path.split(File::SEPARATOR) unless Array === path
      @children ||= {}
      if path.length == 1
        @children[path.first] = url
      else
        @children[path.first] ||= FilesTree.new
        @children[path.first].add(path[1, path.length], url)
      end
    end
  end

  def generate_file_tree
    if @files.length > 1
      @files_tree = FilesTree.new
      @files.each do |file|
        @files_tree.add(file.relative_name, file.path)
      end
      [['', '', 'files', generate_file_tree_level(@files_tree)]]
    else
      []
    end
  end

  def generate_file_tree_level(tree)
    tree.children.keys.sort.map do |name|
      child = tree.children[name]
      if String === child
        [name, child, '', []]
      else
        ['', '', name, generate_file_tree_level(child)]
      end
    end
  end
end
