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
      pid = Closure::Popen.popen(*command) do |stdin, stdout, stderr|
        if io.respond_to? :read
          while buffer = io.read(4096) do
            stdin.write(buffer)
          end
        else
          stdin.write(io.to_s)
        end
        stdin.close
        out_thread = Thread.new { result = stdout.read }
        err_thread = Thread.new { error  = stderr.read }
        out_thread.join and err_thread.join
        yield(StringIO.new(result)) if block_given?
      end
      Process.waitpid pid
      raise Error, error unless $?.success?
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