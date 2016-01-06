require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs += ["lib", "test"]
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

namespace :gem do

  desc 'Build and install the closure-compiler gem'
  task :install do
    sh "gem build closure-compiler.gemspec"
    sh "gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end

  desc 'Uninstall the closure-compiler gem'
  task :uninstall do
    sh "gem uninstall -x closure-compiler"
  end

end

task :default => :test
