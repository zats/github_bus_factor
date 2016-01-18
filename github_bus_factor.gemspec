# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_bus_factor/version'

Gem::Specification.new do |spec|
  spec.name          = "github_bus_factor"
  spec.version       = GitHubBusFactor::VERSION
  spec.authors       = ["Sash Zats"]
  spec.email         = ["sash@zats.io"]

  spec.summary       = "Is it a good idea to use this GitHub project?"
  spec.description   = "Provides few more parameters to estimate quality of the GitHub project besides stars."
  spec.homepage      = "https://github.com/zats/github_bus_factor"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "octokit", "~> 0.4"
  spec.add_runtime_dependency 'commander', '~> 4.3', '>= 4.3.3'
  spec.add_runtime_dependency "security", "~> 0.1.3"
  spec.add_runtime_dependency 'terminal-table', '~> 1.5', '>= 1.5.2'
  spec.add_runtime_dependency 'faraday-http-cache', '~> 1.2', '>= 1.2.2'
  spec.add_runtime_dependency 'activesupport', '~> 4.2', '>= 4.2.5'
end
