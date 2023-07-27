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

  def test_parses_comment_within_block_with_comment_correctly
    css = ".test_css_1 {/* comment */padding:1rem;}"
    assert_equal css, parse(css)
  end

  def test_parses_nested_block_with_comment_correctly
    css = "::root {.test_css_1{padding:1rem;/* comment */}}"
    assert_equal css, parse(css)
  end

  def test_single_import_parses_correctly
    output = ".test_css_1 {padding:1rem;}"
    assert_equal output, parse("@import \"test_1.css\";")
  end

  def test_import_that_imports_another_file_parses_correctly
    output = ".test_css_1 {padding:1rem;}.app_css {margin:1rem;}"
    assert_equal output, parse("@import \"application.css\";")
  end

  def test_utility_selector_gets_cached
    parse ".test_css_1 {padding:1rem;}"
    assert_equal 1, Deadfire::Interpreter.cached_apply_rules.size
    assert Deadfire::Interpreter.cached_apply_rules[".test_css_1"]
  end

  def test_psuedo_selector_does_not_get_cached
    parse "a:hover {padding:1rem;}"
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_id_selector_does_not_get_cached
    parse "#my_nav {padding:1rem;}"
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_element_selector_does_not_get_cached
    parse "p {padding:1rem;}"
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_attribute_selector_does_not_get_cached
    parse "input[type=\"text\"] {padding:1rem;}"
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_nested_utility_selector_does_not_get_cached
    parse "::root { .nav{padding:1rem;} }"
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_parses_nested_media_query_correctly
    css = <<~CSS
      @media screen and (min-width: 480px) {
        .test_css_1 {padding:1rem;}
      }
    CSS

    parse css
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  private

  def parse(css)
    Deadfire::ParserEngine.new(css).parse
  end
end
