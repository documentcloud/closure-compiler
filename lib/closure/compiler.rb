require 'open3'
require 'stringio'
require 'tempfile'

module Closure
  class CompilationError < StandardError; end

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
      Tempfile.open('closure-compiler-stderr') do |stderr|
        result = IO.popen("#{command} 2> #{stderr.path}", 'w+') do |java_io|
          if io.respond_to? :read
            while buffer = io.read(4096) do
              java_io.write(buffer)
            end
          else
            java_io.write(io.to_s)
          end
          java_io.close_write
          block_given? ? yield(java_io) : java_io.read
        end
        raise CompilationError, File.read(stderr.path) unless $?.success?
        return result
      end
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