require './lib/hotcocoa/version'

Gem::Specification.new do |s|
  s.name    = 'hotcocoa'
  s.version = HotCocoa::VERSION

  s.summary      = 'Cocoa mapping library for MacRuby'
  s.description  = 'HotCocoa is a Cocoa mapping library for MacRuby.  It simplifies the use of complex Cocoa classes using DSL techniques.'
  s.authors      = ['Richard Kilmer',     'Mark Rada']
  s.email        = ['rich@infoether.com', 'mrada@marketcircle.com']
  s.homepage     = 'http://github.com/HotCocoa/hotcocoa'
  s.licenses     = ['MIT']
  s.has_rdoc     = 'yard'
  s.bindir       = 'bin'
  s.extensions   = ['ext/hotcocoa/extconf.rb']
  s.executables << 'hotcocoa'

  s.files            =
    ['Rakefile', '.yardopts', 'bin/hotcocoa'] +
    Dir.glob('lib/**/*.rb')   +
    Dir.glob('template/**/*') +
    Dir.glob('ext/**/*.{c,h,rb}')

  s.test_files       =
    Dir.glob('test/**/*.rb')

  s.extra_rdoc_files =
    ['README.markdown', 'History.markdown'] +
    Dir.glob('docs/**/*.markdown')

  s.add_development_dependency 'minitest',  '~> 2.10'
  s.add_development_dependency 'yard',      '~> 0.7.4'
  s.add_development_dependency 'redcarpet', '~> 1.17'
end
