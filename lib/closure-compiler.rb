module Closure

  VERSION           = "1.0.0"

  COMPILER_VERSION  = "20110119"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = COMPILER_ROOT + "/../vendor/closure-compiler-#{COMPILER_VERSION}.jar"

end

require 'stringio'
require 'closure/popen'
require 'closure/compiler'
