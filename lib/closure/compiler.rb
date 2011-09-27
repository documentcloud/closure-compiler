require 'closure/jar'
require 'closure/online'
require 'stringio'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # Compiles a JavaScript string using one of the backends: a local JAR file or
  # the remote Google's service.
  class Compiler

    # When you create a Compiler, pass in the flags and options. By default the
    # local JAR file is used for compilation. Adding `:online => true` to
    # options makes the Compiler use the online Google's service.
    def initialize(options={})
      @backend = if options.delete :online
                   Online.new options
                 else
                   JAR.new options
                 end
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
