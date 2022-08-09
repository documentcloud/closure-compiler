require_relative 'lib/closure-compiler'

Gem::Specification.new do |s|
  s.name      = 'closure-compiler-updated'
  s.version   = Closure::VERSION
  s.date      = '2021-12-01'
  s.license   = 'Apache-2.0'

  s.homepage    = "http://github.com/hmdne/closure-compiler-updated/"
  s.summary     = "Ruby Wrapper for the Google Closure Compiler. Updated."
  s.description = <<-EOS
    A Ruby Wrapper for the Google Closure Compiler. Updated.
  EOS

  s.authors           = ['Jeremy Ashkenas', 'Jordan Brough', 'hmdne']
  s.email             = 'opensource@documentcloud.org'

  s.require_paths     = ['lib']

  s.rdoc_options      << '--title'    << 'Ruby Closure Compiler' <<
                         '--exclude'  << 'test' <<
                         '--all'

  s.files = Dir['lib/**/*', 'vendor/**/*', 'closure-compiler.gemspec', 'README.textile', 'LICENSE', 'COPYING']

end
