require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'dir_dsl'
require 'file_utils/file_utils'

describe DirDSL do
  include FileUtils

  let(:basedir) { "#{File.dirname(__FILE__)}/.." }

  subject { DirDSL.new("build/test", basedir) }

  after do
    delete_directory "#{basedir}/build"
  end

  it "should create new directory with files at particular folder" do
    subject.build do
      file :name => "Gemfile"
      file :name => "Rakefile", :to_dir => "my_config"
      file :name => "spec/spec_helper.rb", :to_dir => "my_config"
    end

    subject.entry_exist?("Gemfile").should be_true
    subject.entry_exist?("my_config/Rakefile").should be_true
    subject.entry_exist?("my_config/spec_helper.rb").should be_true

    subject.entries_size.should == 3
  end

  it "should create new directory with file created from string" do
    subject.build do
      content :name => "README", :source => "My README file content"
    end

    subject.entry_exist?("README").should be_true
    subject.entries_size.should == 1
  end

  it "should create new directory with file created from file" do
    src = File.open("#{basedir}/Rakefile")
    subject.build do
      content :name => "Rakefile", :source => src
    end

    subject.entry_exist?("Rakefile").should be_true
    subject.entries_size.should == 1
  end

  it "should create new directory with new empty folder" do
    subject.build do
      directory :to_dir => "my_config"
    end

    subject.entry_exist?("my_config").should be_true
  end

  it "should create new directory with new folder" do
    subject.build do
      directory :from_dir => "config", :to_dir => "my_config"
    end

    subject.entry_exist?("my_config").should be_true
  end

  it "should display files in current directory" do
    subject.build do
      directory :from_dir => "spec"
    end

    subject.list.should include "spec_helper.rb"
  end

  it "should display files in specified subdirectory" do
    subject.build do
      directory :from_dir => "lib"
    end

    subject.list("dir_dsl").first.should =~ %r{dir_dsl.rb}
  end

end