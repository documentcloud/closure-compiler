require 'test_helper'

class ClosureCompilerTest < Minitest::Test

  ORIGINAL            = "window.hello = function(name) { return console.log('hello ' + name ); }; hello.squared = function(num) { return num * num; }; hello('world');"

  COMPILED_WHITESPACE = "window.hello=function(name){return console.log(\"hello \"+name)};hello.squared=function(num){return num*num};hello(\"world\");\n"
  COMPILED_SIMPLE     = "window.hello=function(a){return console.log(\"hello \"+a)};hello.squared=function(a){return a*a};hello(\"world\");\n"
  COMPILED_ADVANCED   = "window.a=function(b){return console.log(\"hello \"+b)};hello.b=function(b){return b*b};hello(\"world\");\n"

  def test_whitespace_compression
    js = Compiler.new(:compilation_level => "WHITESPACE_ONLY").compile(ORIGINAL)
    assert js == COMPILED_WHITESPACE
  end

  def test_simple_compression
    js = Compiler.new.compile(ORIGINAL)
    assert js == COMPILED_SIMPLE
  end

  def test_advanced_compression
    js = Compiler.new(:compilation_level => "ADVANCED_OPTIMIZATIONS").compile(ORIGINAL)
    assert js == COMPILED_ADVANCED
  end

  def test_block_syntax
    result = ''
    Compiler.new(:compilation_level => "ADVANCED_OPTIMIZATIONS").compile(ORIGINAL) do |code|
      while buffer = code.read(3)
        result << buffer
      end
    end
    assert result == COMPILED_ADVANCED
  end

  def test_jar_and_java_specifiation
    jar = Dir['vendor/closure-compiler-*.jar'].first
    unless java = ( `which java` rescue nil )
      java = `where java` rescue nil # works on newer windows
    end
    if java
      compiler = Compiler.new(:java => java.strip, :jar_file => jar)
      assert compiler.compress(ORIGINAL) == COMPILED_SIMPLE
    else
      puts "could not `which/where java` skipping test"
    end
  end

  def test_exceptions
    assert_raises(Closure::Error) do
      Compiler.new.compile('1++')
    end
    assert_raises(Closure::Error) do
      Compiler.new.compile('obj = [1 2, 3]')
    end
  end

  def test_stderr_reading
    js = Compiler.new.compile(File.read('test/fixtures/precompressed.js'))
    assert js == File.read('test/fixtures/precompressed-compiled.js')
  end

  def test_permissions
    assert File.executable?(COMPILER_JAR)
  end

  def test_serialize_options
    options = { 'externs' => 'library1.js', "compilation_level" => "ADVANCED_OPTIMIZATIONS" }
    # ["--externs",  "library1.js", "--compilation_level", "ADVANCED_OPTIMIZATIONS"]
    # although Hash in 1.8 might change the order to :
    # ["--compilation_level", "ADVANCED_OPTIMIZATIONS", "--externs",  "library1.js"]
    expected_options = options.to_a.map { |arr| [ "--#{arr[0]}", arr[1] ] }.flatten
    assert_equal expected_options, Closure::Compiler.new.send(:serialize_options, options)
  end

  def test_serialize_options_for_arrays
    compiler = Closure::Compiler.new('externs' => ['library1.js', "library2.js"])
    assert_equal ["--externs", "library1.js", "--externs", "library2.js"], compiler.send(:serialize_options, 'externs' => ['library1.js', "library2.js"])
  end

  def test_compiling_array_of_file_paths
    files = ['test/fixtures/file1.js', 'test/fixtures/file2.js']
    result = Closure::Compiler.new().compile_files(files)

    assert_equal result, File.read('test/fixtures/file1-file2-compiled.js')
  end
end
