# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'project_106/version'

Gem::Specification.new do |spec|
  spec.name          = "project_106"
  spec.version       = Project106::VERSION
  spec.authors       = ["Webonise Lab"]
  spec.email         = ["apurva@weboniselab.com", "ketan@weboniselab.com"]
  spec.description   = %q{Error and Exception Tracking.}
  spec.summary       = %q{Project 106 is a errors and exception tracking system}
  spec.homepage      = %q{http://git.weboniselab.com/webonise-lab/project-106}
  spec.license       = "MIT"

  spec.files         = Dir["{app,lib,config,assets}/**/*"] + ["LICENSE.txt", "Rakefile", "Gemfile", "README.md"]
  spec.executables   << 'project_106'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "activesupport" , '>= 3.0.0', '< 4.0'
  spec.add_dependency "rails"         , '>= 3.0.0', '< 4.0'
end
