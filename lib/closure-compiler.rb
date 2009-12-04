require File.expand_path(File.dirname(__FILE__) + '/closure/compiler')

module Closure

  VERSION           = "0.1.5"

  COMPILER_VERSION  = "20091203"

  JAVA_COMMAND      = 'java'

  COMPILER_JAR      = File.expand_path(File.dirname(__FILE__) + "/../vendor/closure-compiler-#{COMPILER_VERSION}.jar")

end