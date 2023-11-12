require "test_helper"

class ParserEngineTest < Minitest::Test
  def setup
    Deadfire.configuration.keep_whitespace = false
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Interpreter.cached_apply_rules = {}
  end

  def teardown
    Deadfire.reset
    Deadfire::Interpreter.cached_apply_rules = {}
  end

  def test_simple_css_parses
    output = ".test_css_1 {padding:1rem;}"
    assert_equal output, css_import_content("test_1.css")
  end

  def test_early_apply_raises_error_when_mixins_not_defined
    assert_error_reported do
      Deadfire::ParserEngine.new("@import \"early_apply_error.css\";")
    end
  end

  def test_at_rule_viewport_parses
    assert_equal "@viewport {width:device-width;}", parse("@viewport { width: device-width; }")
  end

  def test_ruleset_parses
    assert_equal ".header {color:red;}", parse(".header { color: red; }")
  end

  def test_ruleset_with_underscore_parses
    assert_equal ".nav_header {color:red;}", parse(".nav_header { color: red; }")
  end

  def test_comment_parses
    assert_equal "/* comment */", parse("/* comment */")
  end

  def test_comment_with_import_ignored_parses
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

  def test_multiline_comment_parses
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

  def test_comment_within_block_parses
    css = ".test_css_1 {/* comment */padding:1rem;}"
    assert_equal css, parse(css)
  end

  def test_nested_block_with_comment_parses
    css = ".body {.test_css_1{padding:1rem;/* comment */}}"
    assert_equal css, parse(css)
  end

  def test_multiline_comment_is_removed_when_config_setting_is_true
    Deadfire.configuration.keep_comments = false
    css = <<~CSS
      /* comment
      @import "test_1.css";
      multilines */
      .test_css_1 {
        padding: 1rem;
      }
    CSS
    assert_equal ".test_css_1 {padding:1rem;}", parse(css)
  end

  def test_single_import_parses
    output = ".test_css_1 {padding:1rem;}"
    assert_equal output, parse("@import \"test_1.css\";")
  end

  def test_import_without_extention_parses
    output = ".test_css_1 {padding:1rem;}"
    assert_equal output, parse("@import \"test_1\";")
  end

  def test_import_that_imports_another_file_parses
    output = ".test_css_1 {padding:1rem;}.app_css {margin:1rem;}"
    assert_equal output, parse("@import \"application.css\";")
  end

  def test_import_from_admin_directory_parses
    output = ".test_css_3 {padding:3rem;}"
    assert_equal output, parse("@import \"admin/test_3.css\";")
  end

  def test_raises_error_when_invalid_import_location
    assert_raises(Deadfire::ImportException) do
      css_import_content("randomness/test_1")
    end
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

  def test_font_face_parses
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

  def test_multiple_selectors_parses
    css = "h1,h2,h3 {font-weight:bold;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_vendor_prefixes_parses
    css = "h1 {-webkit-box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_important_keyword_parses
    css = "h1 {font-weight:bold !important;}"
    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    refute parser.errors?
  end

  def test_keep_whitespace_successfully
    Deadfire.configuration.keep_whitespace = true
    output = <<~OUTPUT
    .test_css_1  {
      padding: 1rem;
    }
    OUTPUT
    assert_equal output.chomp, css_import_content("test_1.css")
  end

  private

  def parse(css)
    Deadfire::ParserEngine.new(css).parse
  end

  def css_import_content(filename)
    normalized_path = Deadfire::FilenameHelper.normalize_path(filename)
    parse("@import \"#{normalized_path}\";")
  end

  def assert_error_reported
    parser = yield
    parser.parse
    assert parser.errors?
  end
end
