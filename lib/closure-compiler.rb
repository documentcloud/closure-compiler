module Closure

  VERSION           = "1.1.17"

  COMPILER_VERSION  = "v20200824"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = File.join(COMPILER_ROOT, "closure-compiler-#{COMPILER_VERSION}.jar")

end

require_relative 'closure/compiler'
