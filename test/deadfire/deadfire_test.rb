require "test_helper"

class DeadfireTest < Minitest::Test
  def teardown
    Deadfire.reset
  end

  def test_that_it_has_a_version_number
    refute_nil ::Deadfire::VERSION
  end

  def test_deadfire_parses_css
    assert_equal "body {\n  color: red;\n}\n", Deadfire.parse("body {\n  color: red;\n}\n")
  end

  def test_deadfire_parses_with_options
    assert_equal ".test_css_1 {padding:1rem;}body {color:red;}", Deadfire.parse("/*test*/@import \"test_1.css\"; body {\n  color: red;\n}\n", root_path: fixtures_path, compressed: true)
    assert Deadfire.configuration.compressed
  end
end
