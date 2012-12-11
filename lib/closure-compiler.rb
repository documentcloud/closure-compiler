module Closure

  VERSION           = "1.1.7"

  COMPILER_VERSION  = "20120917"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = File.join(COMPILER_ROOT, "closure-compiler-#{COMPILER_VERSION}.jar")

end

require 'closure/compiler'
require 'closure/jruby_runner' if defined?(JRUBY_VERSION)
