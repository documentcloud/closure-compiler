desc 'Run all tests'

task :default => :test
task :test do
  $LOAD_PATH.unshift(File.expand_path('test'))
  require 'redgreen' if Gem.available?('redgreen')
  require 'test/unit'
  Dir['test/**/test_*.rb'].each {|test| require test }
end

namespace :gem do

  desc 'Build and install the closure-compiler gem'
  task :install do
    sh "gem build closure-compiler.gemspec"
    sh "sudo gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end

  desc 'Uninstall the closure-compiler gem'
  task :uninstall do
    sh "sudo gem uninstall -x closure-compiler"
  end

end