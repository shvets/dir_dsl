# DirDSL

Library for working with files and directories (create, copy) in DSL-way

## Installation

Add this line to your application's Gemfile:

    gem 'dir_dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dir_dsl

## Usage

You can create new directory:

```ruby
require 'dir_dsl'

from_dir = "."
to_dir = "build"

dir_builder = DirDSL.new from_dir, to_dir

dir_builder.build do
  # files from 'from_dir'
  file :name => "Gemfile"
  file :name => "Rakefile", :to_dir => "my_config"
  file :name => "spec/spec_helper.rb", :to_dir => "my_config"

  # create empty directory
  directory :to_dir => "my_config"

  # copy from one directory to another
  directory :from_dir => "spec", :to_dir => "my_spec"


  # create zip entry from arbitrary source: string or StringIO
  content :name => "README", :source => "My README file content"
end
```

You can also display all entries from the folder:

```ruby
...

dir_builder.list("lib/zip_dsl")
```

The idea is to build API identical to [ZipDSL] (https://github.com/shvets/zip_dsl), so you can use same API
for building zip files and copying files.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request