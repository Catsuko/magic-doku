# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'magic_doku'
  s.authors     = 'Lewis Reid'
  s.version     = '0.0.1'
  s.summary     = 'Provides MtG based puzzles'

  s.require_paths = 'lib'
  s.files         = Dir.glob('{lib,data,config}/**/*')

  s.required_ruby_version = '>= 3.2.2'

  s.add_dependency('json', '~> 2.7')
  s.add_dependency('yaml')
end
