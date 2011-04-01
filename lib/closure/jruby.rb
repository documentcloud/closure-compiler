require 'java'
require 'stringio'
require Closure::COMPILER_JAR

module Closure
  java_import 'java.io.PrintStream'
  java_import 'com.google.javascript.jscomp.JSSourceFile'
  java_import 'com.google.javascript.jscomp.CommandLineRunner'

  class MyClosureRunner < CommandLineRunner
    def initialize(io, opts = [])
      @io = io
      @result_io = StringIO.new
      @error_io = StringIO.new

      super(
        opts.to_java(:string),
        PrintStream.new(@result_io.to_outputstream),
        PrintStream.new(@error_io.to_outputstream)
      )
    end

    def createInputs(files, allowStdIn)
      stream = if @io.respond_to? :to_inputstream
        @io.to_inputstream
      else
        StringIO.new(@io, 'r').to_inputstream
      end

      inputs = Java::JavaUtil::ArrayList.new
      inputs.add(JSSourceFile.fromInputStream("io", stream));
      inputs
    end

    def result
      @result_io.string
    end

    def error
      @error_io.string
    end

    def close
      @error_io.close unless @error_io.closed?
      @result_io.close unless @result_io.closed?
    end
  end

  class Compiler
    def initialize(options={})
      opts = options.dup
      [:java, :jar_file].each { |bad| opts.delete(bad) }
      @options  = serialize_options(opts)
    end

    def compile(io)
      runner = MyClosureRunner.new(io, @options)
      status = runner.doRun
      raise Error, runner.error if status != 0
      yield(StringIO.new(runner.result)) if block_given?
      runner.result
    ensure
      runner.close
    end

    alias_method :compress, :compile
  end
end
