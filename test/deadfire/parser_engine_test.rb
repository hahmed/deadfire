require "test_helper"

class ParserTest < Minitest::Test
  def test_parser_engine_returns_css
    assert_equal "@viewport {width:device-width;}", Deadfire::ParserEngine.new("@viewport { width: device-width; }").parse
  end

  def test_parser_engine_returns_css_for_ruleset
    assert_equal ".header {color:red;}", Deadfire::ParserEngine.new(".header { color: red; }").parse
  end
end
