require 'open3'
require 'stringio'

module Closure

  class Compiler

    def initialize(options={})
      @options = serialize_options(options)
    end

    def compile(io)
      io = io.respond_to?(:read) ? io.read : io
      Open3.popen3(*command) do |stdin, stdout, stderr|
        stdin.write(io)
        stdin.close
        block_given? ? yield(stdout) : stdout.read
      end
    end
    alias_method :compress, :compile


    private

    def serialize_options(options)
      options.map {|k, v| ["--#{k}", v.to_s] }.flatten
    end

    def command
      ['java', '-jar', COMPILER_JAR, @options].flatten
    end

  end
end