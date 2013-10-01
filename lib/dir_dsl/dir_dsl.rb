require 'file_utils/file_utils'

class DirDSL
  include FileUtils

  attr_reader :from_root, :to_root

  def initialize from_root, to_root
    @from_root = File.expand_path(from_root)
    @to_root = File.expand_path(to_root)
  end

  def build(&block)
    self.instance_eval(&block)
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
    list = pattern_to_files"#{from_root}/#{dir}", "**/*"

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
    if params[:from_dir].nil?
      to_dir = "#{to_root}/#{params[:to_dir]}"

      create_directory to_dir unless File.exist? to_dir
    else
      if params[:to_dir] == "." || params[:to_dir].nil?
        to_dir = params[:from_dir]
      else
        to_dir = params[:to_dir]
      end

      filter = params[:filter].nil? ? "**/*" : params[:filter]

      copy_files "#{from_root}/#{params[:from_dir]}", "#{to_root}/#{to_dir}", filter
    end
  end

  private

  def to_dir dir, name
    if dir.nil?
      from_dir = File.dirname(name)
      to_dir = (from_dir == ".") ? to_root : "#{to_root}/#{from_dir}"
    else
      to_dir = (dir == ".") ? to_root : "#{to_root}/#{dir}"
    end

    to_dir
  end

end

