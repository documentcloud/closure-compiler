require 'java'
module Closure
  require COMPILER_JAR
  class JRubyRunner < com.google.javascript.jscomp.CommandLineRunner
    def self.run(args)
      output_contents = java.io.ByteArrayOutputStream.new
      output = java.io.PrintStream.new(output_contents)
      error_contents = java.io.ByteArrayOutputStream.new
      error = java.io.PrintStream.new(error_contents)
      runner = JRubyRunner.new(args.to_java(:String), output, error)
      runner.do_run
      if !error_contents.to_s.empty?
        raise Error, "compression failed: #{error_contents.to_s}"
      end
      output_contents.to_s
    ensure
      output.close
      error.close
    end

    def createCompiler
      compiler = com.google.javascript.jscomp.Compiler.new(getErrorPrintStream())
      # It would be nice to leave threads enabled but if we do then
      # any process using this must wait at least 60 seconds after
      # using closure-compiler before the process will exit, due to
      # the underlying JVM thread pool keeping threads alive until
      # they time out, which is 60 seconds.
      compiler.disable_threads
      compiler
    end
  end
end
