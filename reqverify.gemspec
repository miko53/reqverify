# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0.0'
  s.name = 'reqverify'
  s.version = '0.0.1'
  s.date = '2023-08-16'
  s.summary = 'creation of traceability matrices'
  s.description = 'set of tools to create traceability matrices'
  s.authors = ['miko53']
  s.email = 'miko53@free.fr'
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['tests/**/*']
  s.homepage = 'https://github.com/miko53/reqverify'
  s.licenses = ['BSD-3-Clause']
  s.add_runtime_dependency('caxlsx', '~> 3.4.1')
  s.add_runtime_dependency('docx', '~> 0.8.1')
  s.add_runtime_dependency('roo-xls', '~> 1.2.0')
end
