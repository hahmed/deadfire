require "test_helper"

class DeadfireTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Deadfire::VERSION
  end
end
