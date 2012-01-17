require 'stringio'
require 'tempfile'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # The Closure::Compiler is a basic wrapper around the actual JAR. There's not
  # much to see here.
  class Compiler

    DEFAULT_OPTIONS = {:warning_level => 'QUIET'}

    # When you create a Compiler, pass in the flags and options.
    def initialize(options={})

      # load closure.jar in same jruby jvm
      if defined?(JRUBY_VERSION)
        jar_path = File.expand_path "../closure-compiler-20111003.jar", File.dirname(__FILE__)
        require jar_path
        @options = DEFAULT_OPTIONS.merge(options)
      else
        @java     = options.delete(:java)     || JAVA_COMMAND
        @jar      = options.delete(:jar_file) || COMPILER_JAR
        @options  = serialize_options(DEFAULT_OPTIONS.merge(options))
      end
    end

    # Can compile a JavaScript string or open IO object. Returns the compiled
    # JavaScript as a string or yields an IO object containing the response to a
    # block, for streaming.
    def compile(io)

      # don't fork a java process.
      if defined?(JRUBY_VERSION)
        
        # load java classes.
        require 'java'
        import com.google.javascript.jscomp.JSSourceFile
        import com.google.javascript.jscomp.Compiler
        import com.google.javascript.jscomp.VariableRenamingPolicy
        import com.google.javascript.jscomp.CompilerOptions
        import com.google.javascript.jscomp.CompilationLevel
        import com.google.javascript.jscomp.WarningLevel

        import java.util.logging.Level
        com.google.javascript.jscomp.Compiler.setLoggingLevel(Level::WARNING)

        compiler =  com.google.javascript.jscomp.Compiler.new()
        opts = CompilerOptions.new

        # simple settings
        compilation_level = @options[:compilation_level] || 'SIMPLE_OPTIMIZATIONS'
        warning_level = @options[:warning_level]

        CompilationLevel.const_get(compilation_level).setOptionsForCompilationLevel(opts)
        WarningLevel.const_get(warning_level).setOptionsForWarningLevel(opts)

        # TODO: add js name.
        source = JSSourceFile.fromCode("unknown", io)

        res = compiler.compile([], [source], opts)
        result = compiler.toSource() + "\n"

        raise Error, result unless res.success

        yield(StringIO.new(result)) if block_given?
        return result
      else
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
          result = `#{command} --js #{tempfile.path} 2>&1`
        rescue Exception
          raise Error, "compression failed: #{result}"
        ensure
          tempfile.close!
        end
        unless $?.exitstatus.zero?
          raise Error, result
        end

        yield(StringIO.new(result)) if block_given?
        result
      end
    end
    alias_method :compress, :compile


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
