require 'file_utils/file_utils'
require 'meta_methods/meta_methods'

class DirDSL
  include FileUtils
  include MetaMethods

  attr_reader :from_root, :to_root

  def initialize from_root, to_root
    @from_root = File.expand_path(from_root)
    @to_root = File.expand_path(to_root)
    @global_ignores = []
  end

  def build(&block)
    evaluate_dsl(self, nil, block)
  end

  def global_ignore ignore
    @global_ignores << ignore
  end

  def entry_exist? entry_name
    File.exist? "#{to_root}/#{entry_name}"
  end

  def entries_size
    list = Dir.glob("#{to_root}/**/*")

    cnt = 0
    list.each do |name|
      cnt += 1 if File.file?(name)
    end

    cnt
  end

  def list dir="."
    list = pattern_to_files "#{from_root}/#{dir}", "**/*"

    list.each_with_index do |name, index|
      list[index] = name["#{from_root}/#{dir}".length+1..-1]
    end
  end

  def file params
    to_dir = to_dir(params[:to_dir], params[:name])

    create_directory to_dir unless File.exist? to_dir

    write_to_file "#{from_root}/#{params[:name]}", "#{to_dir}/#{File.basename(params[:name])}"
  end

  def content params
    source = params[:source]

    stream = source.kind_of?(String) ? StringIO.new(source) : source
    content = stream.read

    to_dir = to_dir(params[:to_dir], params[:name])

    create_directory to_dir unless File.exist? to_dir

    write_content_to_file content, "#{to_dir}/#{File.basename(params[:name])}"
  end

  def directory params
    if params[:from_dir]
      if params[:to_dir] == "." || params[:to_dir].nil?
        to_dir = params[:from_dir]
      else
        to_dir = params[:to_dir]
      end

      filter = params[:filter].nil? ? "**/*" : params[:filter]
      excludes = parse_excludes(params[:excludes])

      copy_files_with_excludes "#{from_root}/#{params[:from_dir]}", "#{to_root}/#{to_dir}", filter, excludes
    else
      to_dir = "#{to_root}/#{params[:to_dir]}"

      create_directory to_dir unless File.exist? to_dir
    end
  end

  private

  def to_dir dir, name
    dir = File.dirname(name) unless dir

    if dir == "."
      to_root
    else
      "#{to_root}/#{dir}"
    end
  end

  def parse_excludes excludes
    if excludes
      excludes.split(",").map(&:strip)
    else
      []
    end
  end

  def copy_files_with_excludes from_dir, to_dir, pattern, excludes
    create_directory to_dir

    files = pattern_to_files from_dir, pattern

    files.each do |file|
      if File.file? file and not file_excluded(file, excludes)
        FileUtils.cp(file, to_dir)
      elsif File.directory?(file) and not dir_in_global_ignores(file, @global_ignores)
        FileUtils.mkdir_p file
      end
    end
  end

  def dir_in_global_ignores dir, global_ignores
    ignored = false

    global_ignores.each do |exclude|
      if dir =~ /#{exclude}/
        ignored = true
        break
      end
    end

    ignored
  end

  def file_excluded(file, excludes)
    excluded = false

    excludes.each do |exclude|
      if file =~ /#{exclude}/
        excluded = true
        break
      end
    end

    excluded
  end

end

