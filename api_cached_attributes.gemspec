# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_cached_attributes/version'

Gem::Specification.new do |spec|
  spec.name        = 'remote-resource'
  spec.version     = ApiCachedAttributes::VERSION
  spec.authors     = ['Chris Ewald']
  spec.email       = ['chrisewald@gmail.com']

  spec.summary     = 'Define and associate remote resources with speed and resiliency.'
  spec.description = 'See readme'
  spec.homepage    = "https://github.com/mkcode/remote-resource"
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 3.2'

  spec.add_development_dependency 'rake', '>= 11.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'octokit'
  spec.add_development_dependency 'activerecord', '>= 3.2'
  spec.add_development_dependency 'redis', '>= 3.2'
end
