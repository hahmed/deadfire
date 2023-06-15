require "test_helper"

class ParserTest < Minitest::Test
  def test_parser_engine_returns_css
    assert_equal "@viewport {width:device-width;}", Deadfire::ParserEngine.new("@viewport { width: device-width; }").parse
  end
end
