require 'file_utils/file_utils'
require 'meta_methods'

class DirDSL
  include FileUtils
  include MetaMethods

  def initialize name, basedir
    @name = name
    @basedir = File.expand_path(basedir)
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    evaluate_dsl(self, nil, execute_block)
  end

  def entry_exist? entry_name
    File.exist? full_name("#@name/#{entry_name}")
  end

  def entries_size
    list = Dir.glob("#{full_name(@name)}/**/*")

    cnt = 0
    list.each do |name|
      cnt += 1 if File.file?(name)
    end

    cnt
  end

  def list dir="."
    list = pattern_to_files full_name("#@name/#{dir}"), "**/*"

    list.each_with_index do |name, index|
      list[index] = name[full_name("#@name/#{dir}").length+1..-1]
    end
  end

  def file params
    to_dir = to_dir(params[:name], params[:to_dir])

    create_directory full_name(to_dir)

    write_to_file full_name(params[:name]), full_name("#{to_dir}/#{File.basename(params[:name])}")
  end

  def content params
    source = params[:source]

    stream = source.kind_of?(String) ? StringIO.new(source) : source
    content = stream.read

    to_dir = to_dir(params[:name], params[:to_dir])

    create_directory full_name(to_dir)

    write_content_to_file content, full_name("#{to_dir}/#{File.basename(params[:name])}")
  end

  def directory params
    if params[:from_dir].nil?
      create_empty_directory params[:to_dir]
    else
      if params[:to_dir] == "." || params[:to_dir].nil?
        to_dir = "#@name"
      else
        to_dir = "#@name/#{params[:to_dir]}"
      end

      filter = params[:filter].nil? ? "**/*" : params[:filter]

      copy_files full_name(params[:from_dir]), full_name(to_dir), filter
    end
  end

  private

  def to_dir name, dir
    if dir.nil?
      from_dir = File.dirname(name)
      (from_dir == ".") ? @name : "#@name/#{from_dir}"
    else
      (dir == ".") ? @name : "#@name/#{dir}"
    end
  end

  def create_empty_directory dir
    to_dir = (dir == ".") ? @name : "#@name/#{dir}"

    create_directory full_name(to_dir)
  end

  def full_name? name
    File.expand_path(name) == name
  end

  def full_name name
    full_name?(name) ? name : "#@basedir/#{name}"
  end

end
