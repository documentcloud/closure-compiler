require 'stringio'
require 'tempfile'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # The Closure::Compiler is a basic wrapper around the actual JAR. There's not
  # much to see here.
  class Compiler

    attr_accessor :options
    
    DEFAULT_OPTIONS = {
      :warning_level => 'QUIET',
      :language_in => 'ECMASCRIPT5'
    }

    # When you create a Compiler, pass in the flags and options.
    def initialize(options={})
      @java     = options.delete(:java)     || JAVA_COMMAND
      @jar      = options.delete(:jar_file) || COMPILER_JAR
      @options  = DEFAULT_OPTIONS.merge(options)
    end

    # Can compile a JavaScript string or open IO object. Returns the compiled
    # JavaScript as a string or yields an IO object containing the response to a
    # block, for streaming.
    def compile(io)
      tempfile = Tempfile.new('closure_compiler')
      if io.respond_to? :read
        while buffer = io.read(4096) do
          tempfile.write(buffer)
        end
      else
        tempfile.write(io.to_s)
      end
      tempfile.flush

      begin
        result = compile_files(tempfile.path)
      rescue Exception => e
        raise e
      ensure
        tempfile.close!
      end

      yield(StringIO.new(result)) if block_given?
      result
    end
    alias_method :compress, :compile

    # Takes an array of javascript file paths or a single path. Returns the
    # resulting JavaScript as a string or yields an IO object containing the
    # response to a block, for streaming.
    def compile_files(files)
      @options.merge!(:js => files)

      begin
        result = `#{command} 2>&1`
      rescue Exception
        raise Error, "compression failed: #{result}"
      end

      unless $?.exitstatus.zero?
        raise Error, result
      end

      yield(StringIO.new(result)) if block_given?
      result
    end
    alias_method :compile_file, :compile_files

    private

    # Serialize hash options to the command-line format.
    def serialize_options(options)
      options.map do |k, v|
        if (v.is_a?(Array))
          v.map {|v2| ["--#{k}", v2.to_s]}
        else
          ["--#{k}", v.to_s]
        end
      end.flatten
    end

    def command
      [@java, '-jar', "\"#{@jar}\"", serialize_options(@options)].flatten.join(' ')
    end

  end
end
