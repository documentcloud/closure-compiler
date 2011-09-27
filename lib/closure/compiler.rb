require 'stringio'
require 'tempfile'
require 'net/http'
require 'uri'

module Closure

  # We raise a Closure::Error when compilation fails for any reason.
  class Error < StandardError; end

  # The Closure::Compiler is a basic wrapper around the actual JAR. There's not
  # much to see here.
  class Compiler

    DEFAULT_OPTIONS = { :compilation_level => :SIMPLE_OPTIMIZATIONS,
      :output_format => :text, :output_info => :compiled_code }

    SEVICE_URI = URI.parse 'http://closure-compiler.appspot.com/compile'

    # When you create a Compiler, pass in the flags and options.
    def initialize(options={})
      @options = DEFAULT_OPTIONS.merge options
      load_externs if @options['externs']
    end

    # Can compile a JavaScript string or open IO object. Returns the compiled
    # JavaScript as a string or yields an IO object containing the response to a
    # block, for streaming.
    def compile(io)
      if io.respond_to? :read
        code = io.read
      else
        code = io
      end

      begin
        result = query_the_service code
      rescue Exception
        raise Error, "compression failed"
      end

      yield(StringIO.new(result)) if block_given?
      result
    end
    alias_method :compress, :compile


    private

    def query_the_service code
      res = Net::HTTP.post_form SEVICE_URI, @options.merge({:js_code => code})
      if res.is_a? Net::HTTPSuccess and not is_error? res.body
        res.body
      else
        raise res.body
      end
    end

    def is_error? response
      response.empty? or response == "\n" or response =~ /^Error\(\d+\):/
    end

    def load_externs
      extern_code = @options['externs'].reduce '' do |code, filename|
        code + File.read(filename)
      end
      @options['js_externs'] = extern_code
      @options.delete 'externs'
    end
  end
end
