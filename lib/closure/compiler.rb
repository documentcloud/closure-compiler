require 'closure/jar'
require 'stringio'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # Compiles a JavaScript string using one of the backends: a local JAR file or
  # the remote Google's service.
  class Compiler

    # When you create a Compiler, pass in the flags and options.
    def initialize(options={})
      @backend = JAR.new options
    end

    # Can compile a JavaScript string or open IO object. Returns the compiled
    # JavaScript as a string or yields an IO object containing the response to a
    # block, for streaming.
    def compile(io)
      result = @backend.compile io
      yield(StringIO.new(result)) if block_given?
      result
    end
    alias_method :compress, :compile
  end
end
