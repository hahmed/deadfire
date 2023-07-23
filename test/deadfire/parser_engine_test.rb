require "test_helper"

class ParserTest < Minitest::Test
  def test_parse_at_rule_viewport_successfully
    assert_equal "@viewport {width:device-width;}", parse("@viewport { width: device-width; }")
  end

  def test_parse_ruleset_successfully
    assert_equal ".header {color:red;}", parse(".header { color: red; }")
  end

  def test_parse_ruleset_with_underscore
    assert_equal ".nav_header {color:red;}", parse(".nav_header { color: red; }")
  end

  private

  def parse(css)
    Deadfire::ParserEngine.new(css).parse
  end
end
