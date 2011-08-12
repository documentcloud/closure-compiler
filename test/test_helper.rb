if defined?(Gem) and Gem.available?('redgreen')
  require 'redgreen' if RUBY_VERSION < "1.9"
end
require 'test/unit'

require 'closure-compiler'

class Test::Unit::TestCase
  include Closure
end
