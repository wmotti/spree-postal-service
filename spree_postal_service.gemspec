# coding: utf-8
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'spree_postal_service'
  s.version      = version
  s.summary      = 'Calculate weight based charges for a Spree order'
  s.description  = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.author       = 'Torsten Ruger'
  s.email        = 'torsten@villataika.fi'
  s.homepage     = 'https://github.com/dancinglightning/spree-postal-service'
  s.license      = 'BSD'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  spree_version  = '~> 2.1.0.beta'
  s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'i18n', '~> 0.6.1'
  s.add_development_dependency 'rails-i18n', '~> 0.7.3'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'rspec-rails', '~> 2.13'
  s.add_development_dependency 'sqlite3', '~> 1.3.7'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'i18n-spec', '~> 0.4.0'
  s.add_development_dependency 'fuubar', '>= 0.0.1'
end
