require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'dir_dsl'
require 'file_utils/file_utils'

describe DirDSL do
  include FileUtils

  let(:from_basedir) { "#{File.dirname(__FILE__)}/.." }
  let(:to_basedir) { "#{File.dirname(__FILE__)}/../build" }

  subject { DirDSL.new(from_basedir, to_basedir) }

  after do
    delete_directory "#{to_basedir}"
  end

  it "should create new directory with files at particular folder" do
    subject.build do
      file :name => "Gemfile"
      file :name => "Rakefile", :to_dir => "my_config"
      file :name => "spec/spec_helper.rb", :to_dir => "my_config"
    end

    expect(subject.entry_exist?("Gemfile")).to be_truthy
    expect(subject.entry_exist?("my_config/Rakefile")).to be_truthy
    expect(subject.entry_exist?("my_config/spec_helper.rb")).to be_truthy

    expect(subject.entries_size).to eq 3
  end

  it "should create new directory with file created from string" do
    subject.build do
      content :name => "README", :source => "My README file content"
    end

    expect(subject.entry_exist?("README")).to be_truthy
    expect(subject.entries_size).to eq 1
  end

  it "should create new directory with file created from file" do
    src = File.open("#{from_basedir}/Rakefile")
    subject.build do
      content :name => "Rakefile", :source => src
    end

    expect(subject.entry_exist?("Rakefile")).to be_truthy
    expect(subject.entries_size).to eq 1
  end

  it "should create new directory with new empty folder" do
    subject.build do
      directory :to_dir => "my_config"
    end

    expect(subject.entry_exist?("my_config")).to be_truthy
  end

  it "should create new directory with new folder" do
    subject.build do
      directory :from_dir => "config", :to_dir => "my_config"
    end

    expect(subject.entry_exist?("my_config")).to be_truthy
  end

  it "should display files in current directory" do
    subject.build do
      directory :from_dir => "spec"
    end

    expect(subject.entry_exist?("spec/spec_helper.rb")).to be_truthy
  end

  it "should display files in specified subdirectory" do
    subject.build do
      directory :from_dir => "lib"
    end

    expect(subject.entry_exist?("lib/dir_dsl.rb")).to be_truthy
  end

  it "should exclude files from result" do
    subject.build do
      directory :from_dir => "lib", :excludes => "version.rb"
    end

    expect(subject.entry_exist?("lib/version.rb")).to be_falsey
  end

end
