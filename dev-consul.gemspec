# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dev/consul/version'

Gem::Specification.new do |spec|
  spec.name          = 'dev-consul'
  spec.version       = "#{Dev::Consul::VERSION}.#{Dev::Consul::RELEASE}"
  spec.authors       = ['John Manero']
  spec.email         = ['jmanero@rapid7.com']

  spec.summary       = 'Test/development wrapper for Consul by Hashicorp'
  spec.description   = "dev/consul bundles all of Hashicorp's platform-specific binaries "\
                       'for Consul and provides helpers to detect the local platform '\
                       'and run the right build.'
  spec.homepage      = 'https://github.com/rapid7/dev-consul'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'zipruby', '~> 0.3'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
end
