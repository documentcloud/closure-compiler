require 'rubygems'

if begin
    Gem::Specification::find_by_name 'redgreen'
  rescue Gem::LoadError
    false
  rescue
    Gem.available? 'redgreen'
  end
  require 'redgreen' if RUBY_VERSION < "1.9"
end
require 'minitest/autorun'

require 'closure-compiler'

class MiniTest::Unit::TestCase
  include Closure
end
