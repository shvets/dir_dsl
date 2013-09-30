# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/lib/dir_dsl/version')

Gem::Specification.new do |spec|
  spec.name          = "dir_dsl"
  spec.summary       = %q{Library for working with files and directories file in DSL-way }
  spec.description   = %q{Library for working with files and directories in DSL-way }
  spec.email         = "alexander.shvets@gmail.com"
  spec.authors       = ["Alexander Shvets"]
  spec.homepage      = "http://github.com/shvets/dir_dsl"

  spec.files         = `git ls-files`.split($\)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.version       = DirDSL::VERSION

  
  spec.add_runtime_dependency "meta_methods", [">= 0"]
  spec.add_runtime_dependency "file_utils", [">= 0"]
  spec.add_development_dependency "gemspec_deps_gen", [">= 0"]
  spec.add_development_dependency "gemcutter", [">= 0"]

end

