Gem::Specification.new do |s|
  s.name           = 'tumblr_autofixer'
  s.version        = '0.0.1'
  s.authors        = ['Meissa Dia']
  s.email          = ['meissadia@gmail.com']
  s.homepage       = 'https://github.com/meissadia/tumblr_autofixer'
  s.license        = 'Apache-2.0'
  s.date           = Date.today.to_s
  s.summary        = 'Customizable automated comment generator.'

  s.description    = %(
  Customizable automated comment generator!
  )

  s.files          = Dir.glob('{bin,lib}/**/*') + ['README.md']
  s.executables    = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files     = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths  = ['lib']

  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency 'tumblr_draftking', '~> 0.9.0'
  s.add_runtime_dependency 'psych', '2.0.8'
  s.add_runtime_dependency 'sanitize', '4.5.0'

end
