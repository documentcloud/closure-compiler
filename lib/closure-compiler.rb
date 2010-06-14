module Closure

  VERSION           = "0.3.2"

  COMPILER_VERSION  = "20100514"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = COMPILER_ROOT + "/../vendor/closure-compiler-#{COMPILER_VERSION}.jar"

end

require 'stringio'
require Closure::COMPILER_ROOT + '/closure/popen'
require Closure::COMPILER_ROOT + '/closure/compiler'
