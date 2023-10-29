# frozen_string_literal: true

$:.unshift File.expand_path("../lib", __FILE__)

require 'reqv/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0.0'
  s.name = 'reqverify'
  s.version = Reqv::VERSION
  s.date = '2023-10-22'
  s.summary = 'creation of traceability matrices'
  s.description = 'set of tools to create traceability matrices'
  s.authors = ['miko53']
  s.email = 'miko53@free.fr'
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['tests/**/*'] + Dir['README.md', 'CHANGELOG.md', 'LICENSE' ]
  s.executables = Dir['bin/*'].map { |f| File.basename f }
  s.homepage = 'https://github.com/miko53/reqverify'
  s.licenses = ['BSD-3-Clause']
  s.add_runtime_dependency('caxlsx', '~> 3.4.1')
  s.add_runtime_dependency('docx', '~> 0.8.0')
  s.add_runtime_dependency('roo-xls', '~> 1.2.0')
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.7'
end
