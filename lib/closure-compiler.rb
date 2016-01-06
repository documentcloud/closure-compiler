module Closure

  VERSION           = "1.1.12"

  COMPILER_VERSION  = "20151015"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = File.join(COMPILER_ROOT, "closure-compiler-#{COMPILER_VERSION}.jar")

end

require 'closure/compiler'
