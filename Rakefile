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