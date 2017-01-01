# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compare_linker_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'compare_linker_wrapper'
  spec.version       = CompareLinkerWrapper::VERSION
  spec.authors       = ['sanemat']
  spec.email         = ['o.gata.ken@gmail.com']

  spec.summary       = 'CompareLinker CLI wrapper.'
  spec.description   = 'CompareLinker CLI wrapper.'
  spec.homepage      = 'https://github.com/packsaddle/ruby-compare_linker_wrapper'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.1'

  spec.files         = \
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
      .reject do |f|
        [
          '.travis.yml',
          'circle.yml',
          '.tachikoma.yml',
          'package.json'
        ].include?(f)
      end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '>= 0'
  spec.add_runtime_dependency 'git', '>= 0'
  spec.add_runtime_dependency 'bundler', '>= 0'
  spec.add_runtime_dependency 'octokit', '>= 0'
  spec.add_runtime_dependency 'compare_linker', '>= 0'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'test-unit', '>= 0'
end
