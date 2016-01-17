# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_score/version'

Gem::Specification.new do |spec|
  spec.name          = "github_score"
  spec.version       = GithubScore::VERSION
  spec.authors       = ["Sash Zats"]
  spec.email         = ["sash@zats.io"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "octokit", "~> 0.4"
  spec.add_development_dependency "commander", "~> 4.3.3"
  spec.add_development_dependency "security", "~> 0.1.3"
  spec.add_development_dependency "terminal-table", "~> 1.5.2"
  spec.add_development_dependency "faraday-http-cache", "~> 1.2.2"
  spec.add_development_dependency "activesupport", "~> 4.2.5"
end
