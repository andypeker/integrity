require "test/unit"
require "rr"
require "extlib"
require "dm-sweatshop"
require "contest"
require "sqlite3"

require "integrity"
require "fixtures"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

INTEGRITY_TEST_TMP = File.expand_path(File.dirname(__FILE__) + "/../tmp")

class IntegrityTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit
  include Integrity

  def setup
    Integrity.configure { |c|
      c.database  = "sqlite3:db/test.db"
      c.directory = INTEGRITY_TEST_TMP
      c.base_url  = "http://www.example.com"
      c.log       = "test.log"
      c.username  = "admin"
      c.password  = "test"
    }

    Thread.abort_on_exception = true
    DataMapper.auto_migrate!
  end

  class << self
    alias_method :it, :test
  end

  def assert_change(object, method, difference=1)
    initial_value = object.send(method)
    ret = yield
    assert_equal initial_value + difference, object.send(method)
    ret
  end

  def assert_no_change(object, method, &block)
    assert_change(object, method, 0, &block)
  end

  # Do not output warnings for the duration of the block.
  def silence_warnings
    $VERBOSE, v = nil, $VERBOSE
    yield
  ensure
    $VERBOSE = v
  end
end
