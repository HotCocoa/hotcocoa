$LOAD_PATH.unshift File.expand_path 'lib'
require 'hotcocoa/version'

Gem::Specification.new do |s|
  s.name    = 'hotcocoa'
  s.version = HotCocoa::VERSION

  s.summary       = 'Cococa mapping library for MacRuby'
  s.description   =<<-EOS
HotCocoa is a Cocoa mapping library for MacRuby.  It simplifies the use of complex Cocoa classes using DSL techniques.
  EOS
  s.authors       = ['Richard Kilmer',     'Mark Rada']
  s.email         = ['rich@infoether.com', 'mrada@marketcircle.com']
  s.homepage      = 'http://github.com/ferrous26/hotcocoa'
  s.licenses      = ['MIT']
  s.has_rdoc      = 'yard'
  s.bindir        = 'bin'
  s.executables  << 'hotcocoa'

  s.files            = Dir.glob("{lib,template,bin}/**/*")
  s.test_files       = Dir.glob('test/**/*.rb') + ['Rakefile']
  s.extra_rdoc_files = [
                        'README.markdown',
                        'History.txt',
                        '.yardopts'
                       ]

  s.add_development_dependency 'minitest-macruby-pride', '~> 2.3.2'
  s.add_development_dependency 'yard',                   '~> 0.7.2'
  s.add_development_dependency 'redcarpet',              '~> 1.17'
end
