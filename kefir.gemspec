# encoding: utf-8
require File.expand_path('../lib/kefir/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'kefir'
  s.version = Kefir::VERSION
  s.authors = ['Nick Tomlin']
  s.email = ['nick.tomlin@gmail.com']
  s.summary = 'Simple configuration for your application/gem'
  s.licenses = ['']

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop', '~> 0.45'
end
