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

  def test_parses_nested_media_query_correctly_and_block_is_not_cached
    css = <<~CSS
      @media screen and (min-width: 480px) {
        .test_css_1 {padding:1rem;}
      }
    CSS

    parse css
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_parses_keyframes_correctly_and_block_is_not_cached
    css = <<~CSS
      @keyframes slidein {
        from {
          margin-left: 100%;
          width: 300%;
        }

        to {
          margin-left: 0%;
          width: 100%;
        }
      }
    CSS

    parse css
    assert_equal 0, Deadfire::Interpreter.cached_apply_rules.size
  end

  def test_parses_font_face_correctly
    css = <<~CSS
    @font-face {
      font-family: "MyFont";
      src: url("font.woff2");
    }
    CSS

    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_parses_multiple_selectors_correctly
    css = "h1,h2,h3 {font-weight:bold;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_parses_vendor_prefixes_correctly
    css = "h1 {-webkit-box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_parses_important_keyword_correctly
    css = "h1 {font-weight:bold !important;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_nest_selector_used_on_its_own
    css = ".foo {color:blue; & > .bar{color:red;}}"
    output = ".foo {color:blue;}.foo >.bar {color:red;}"

    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert_equal output, parser.parse
  end

  # focus
  def test_nest_in_compound_selector
    css = ".foo {color:blue; &.bar{color:red;}}"
    output = ".foo {color:blue;}.foo.bar {color:red;}"

    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert_equal output, parser.parse
  end

  def test_multiple_selectors_unfold_when_correct_starting_selector_is_used
    skip

    css = ".foo, .bar {.foo, .bar { color: blue; } :is(.foo, .bar) + .baz, :is(.foo, .bar).qux { color: red; }}"
    output = ".foo {color:blue;}.foo.bar {color:red;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert_equal output, parser.parse
  end

  focus
  def test_selectors_can_be_used_multiple_times_in_single_selector
    css = ".foo {color:blue; & .bar & .baz & .qux { color: red; }}"
    output = ".foo {color:blue;}.foo .bar .foo .baz .foo .qux { color: red; }"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert_equal output, parser.parse
  end

  private

  def parse(css)
    Deadfire::ParserEngine.new(css).parse
  end
end
