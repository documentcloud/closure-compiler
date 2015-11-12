Gem::Specification.new do |s|
  s.name      = 'closure-compiler'
  s.version   = '1.1.12'            # Keep version in sync with closure-compiler.rb
  s.date      = '2015-11-12'
  s.license   = 'Apache-2.0'

  s.homepage    = "http://github.com/documentcloud/closure-compiler/"
  s.summary     = "Ruby Wrapper for the Google Closure Compiler"
  s.description = <<-EOS
    A Ruby Wrapper for the Google Closure Compiler.
  EOS

  s.rubyforge_project = "closure-compiler"
  s.authors           = ['Jeremy Ashkenas', 'Jordan Brough']
  s.email             = 'opensource@documentcloud.org'

  s.require_paths     = ['lib']

  s.rdoc_options      << '--title'    << 'Ruby Closure Compiler' <<
                         '--exclude'  << 'test' <<
                         '--all'

  s.files = Dir['lib/**/*', 'vendor/**/*', 'closure-compiler.gemspec', 'README.textile', 'LICENSE', 'COPYING']

end
