lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'light_aip_creation/version'

Gem::Specification.new do |s|
  s.name          = 'light_aip_creation'
  s.version       = LightAipCreation::VERSION
  s.date          = '2017-08-31'
  s.authors       = ['DI Team U of A']
  s.email         = 'strilets@ualberta.ca'
  s.files         = ['lib/light_aip_creation.rb']

  s.summary       = 'This is gems that allows depositing files into openstack swift repository'
  s.description   = 'Gem to deposit files into swift reposiroty'
  s.homepage      = 'http://rubygems.org/gems/light_aip_creation'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.3.1'

  s.add_runtime_dependency 'activesupport', '~> 5.0'

  s.add_development_dependency 'bundler', '~> 1.14'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.45'
  s.add_development_dependency 'rubocop-rspec', '~> 1.10'
  s.add_development_dependency 'pry', '~> 0.10', '>= 0.10.4'
  s.add_development_dependency 'webmock', '~> 2.1'
end
