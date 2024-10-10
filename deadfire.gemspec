require_relative 'lib/deadfire/version'

Gem::Specification.new do |spec|
  spec.name          = "deadfire"
  spec.version       = Deadfire::VERSION
  spec.authors       = ["Haroon Ahmed"]
  spec.email         = ["haroon.ahmed25@gmail.com"]

  spec.summary       = "Deadfire - lightweight css preprocessor"
  spec.homepage      = "https://github.com/hahmed/deadfire"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hahmed/deadfire"
  spec.metadata["changelog_uri"] = "https://github.com/hahmed/deadfire/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", ">= 7.0.0"
  spec.add_dependency "activesupport", ">= 7.0.0"
  spec.add_dependency "railties", ">= 7.0.0"
  spec.add_dependency "propshaft", ">= 0.9.0"
end
