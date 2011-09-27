require 'tempfile'

module Closure
  # The Closure::JAR is a basic wrapper around the actual JAR. There's not
  # much to see here.
  class JAR

    DEFAULT_OPTIONS = {:warning_level => 'QUIET'}

    def initialize(options = {})
      @java     = options.delete(:java)     || JAVA_COMMAND
      @jar      = options.delete(:jar_file) || COMPILER_JAR
      @options  = serialize_options(DEFAULT_OPTIONS.merge(options))
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
        result = `#{command} --js #{tempfile.path}`
      rescue Exception
        raise Error, "compression failed"
      ensure
        tempfile.close!
      end
      unless $?.exitstatus.zero?
        raise Error, result
      end

      result
    end

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
      [@java, '-jar', "\"#{@jar}\"", @options].flatten.join(' ')
    end
  end
end
