require "test_helper"

class ParserEngineTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Interpreter.cached_apply_rules = {}
  end

  def teardown
    Deadfire.reset
    Deadfire::Interpreter.cached_apply_rules = {}
  end

  def test_at_rule_viewport_successfully
    assert_equal "@viewport {width:device-width;}", parse("@viewport { width: device-width; }")
  end

  def test_ruleset_successfully
    assert_equal ".header {color:red;}", parse(".header { color: red; }")
  end

  def test_ruleset_with_underscore
    assert_equal ".nav_header {color:red;}", parse(".nav_header { color: red; }")
  end

  def test_comment_successfully
    assert_equal "/* comment */", parse("/* comment */")
  end

  def test_comment_with_import_ignored
    assert_equal "/* comment @import url('test'); */", parse("/* comment @import url('test'); */")
  end

  def test_multiline_comment_with_import_ignored
    css = <<~CSS
      /* comment
      on
      multlines */
      .test_css_1 {
        padding: 1rem;
      }
    CSS

    output = <<~CSS
      /* comment
      on
      multlines */.test_css_1 {padding:1rem;}
    CSS

    assert_includes output, parse(css)
  end

  def test_multiline_comment_outputs_correctly
    css = <<~CSS
      /* comment
      @import "test_1.css";
      multlines */
      .test_css_1 {
        padding: 1rem;
      }
    CSS

    output = <<~CSS
      /* comment
      @import "test_1.css";
      multlines */.test_css_1 {padding:1rem;}
    CSS

    assert_includes output, parse(css)
  end

  def test_single_import_parses_correctly
    output = ".test_css_1 {padding:1rem;}"
    assert_equal output, parse("@import \"test_1.css\";")
  end

  def test_import_that_imports_another_file_parses_correctly
    output = ".test_css_1 {padding:1rem;}.app_css {margin:1rem;}"
    assert_equal output, parse("@import \"application.css\";")
  end

  def test_mixin_gets_cached
    css = ".test_css_1 {padding:1rem;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert_equal 1, Deadfire::Interpreter.cached_apply_rules.size
    assert Deadfire::Interpreter.cached_apply_rules[".test_css_1"]
  end

  private

  def parse(css)
    Deadfire::ParserEngine.new(css).parse
  end
end
