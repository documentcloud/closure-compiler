require 'rubygems'
require 'popen4'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # The Closure::Compiler is a basic wrapper around the actual JAR. There's not
  # much to see here.
  class Compiler

    # When you create a Compiler, pass in the flags and options.
    def initialize(options={})
      @java     = options.delete(:java)     || JAVA_COMMAND
      @jar      = options.delete(:jar_file) || COMPILER_JAR
      @options  = serialize_options(options)
    end

    # Can compile a JavaScript string or open IO object. Returns the compiled
    # JavaScript as a string or yields an IO object containing the response to a
    # block, for streaming.
    def compile(io)
      result, error = nil, nil
      status = POpen4.popen4(*command) do |stdout, stderr, stdin, pid|
        if io.respond_to? :read
          while buffer = io.read(4096) do
            stdin.write(buffer)
          end
        else
          stdin.write(io.to_s)
        end
        stdin.close
        result = block_given? ? yield(stdout) : stdout.read
        error = stderr.read
      end
      raise Error, error unless status.success?
      result
    end
    alias_method :compress, :compile


    private

    # Serialize hash options to the command-line format.
    def serialize_options(options)
      options.map {|k, v| ["--#{k}", v.to_s] }.flatten
    end

    def command
      [@java, '-jar', @jar, @options].flatten.join(' ')
    end

  end
end