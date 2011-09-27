require 'net/http'
require 'uri'

module Closure

  # Compiles JavaScript strings using Google's online Closure Compiler service.
  # See http://code.google.com/intl/pl-PL/closure/compiler/docs/api-ref.html for
  # a detailed API documentation.
  class Online

    DEFAULT_OPTIONS = { :compilation_level => :SIMPLE_OPTIMIZATIONS,
      :output_format => :text, :output_info => :compiled_code }

    # The endpoint of Google's service to which POST requests will be sent.
    SEVICE_URI = URI.parse 'http://closure-compiler.appspot.com/compile'

    def initialize(options={})
      @options = DEFAULT_OPTIONS.merge options
      load_externs if @options['externs']
    end

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

      result
    end

    private

    # Sends a POST query to the service. Returns a returned string or raises an
    # exception in case of any errors.
    def query_the_service code
      res = Net::HTTP.post_form SEVICE_URI, @options.merge({:js_code => code})
      if res.is_a? Net::HTTPSuccess and not is_error? res.body
        res.body
      else
        raise res.body
      end
    end

    # Returns true if the body of the response sent by the service is empty, a
    # single newline or an error message string.
    #
    # The Closure Compiler service could provide more information about errors
    # which prevented sent code from being compiled but in order to get them
    # we'd have to send another request. Trying to save our quota we won't ask
    # for more.
    def is_error? response
      response.empty? or response == "\n" or response =~ /^Error\(\d+\):/
    end

    # Loads contents of extern files and puts them in the @options hash.
    def load_externs
      extern_code = @options['externs'].reduce '' do |code, filename|
        code + File.read(filename)
      end
      @options['js_externs'] = extern_code
      @options.delete 'externs'
    end
  end
end
