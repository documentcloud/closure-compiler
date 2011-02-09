module Closure

  VERSION           = "1.0.0"

  COMPILER_VERSION  = "20110119"

  JAVA_COMMAND      = 'java'
  
  UGLIFY_PATH       = '~/local/node/bin/uglifyjs'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = COMPILER_ROOT + "/../vendor/closure-compiler-#{COMPILER_VERSION}.jar"

end

require 'stringio'
require Closure::COMPILER_ROOT + '/closure/popen'
require Closure::COMPILER_ROOT + '/closure/compiler'
