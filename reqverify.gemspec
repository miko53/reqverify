# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.0.0'
  s.name = 'reqverify'
  s.version = '0.0.0'
  s.date = '2023-08-16'
  s.summary = 'creation of traceability matrix'
  s.description = 'set of tools to create traceability matrix'
  s.authors = ['miko53']
  s.email = 'miko53@free.fr'
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['tests/**/*']
  s.homepage = 'https://github.com/miko53/reqverify'
  s.licenses = ['BSD-3-Clause']
  s.add_runtime_dependency('axlsx', '~> 2.0.1')
  #   #  s.add_runtime_dependency('byebug'', '~> 0')
  #   s.add_runtime_dependency
end