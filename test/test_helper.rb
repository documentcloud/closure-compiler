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
require 'test/unit'

require 'closure-compiler'

class Test::Unit::TestCase
  include Closure
end
