require "test_helper"

class DeadfireTest < Minitest::Test
  def teardown
    Deadfire.reset
  end

  def test_that_it_has_a_version_number
    refute_nil ::Deadfire::VERSION
  end

  def test_parses_css
    assert_equal "body {\n  color: red;\n}\n", Deadfire.parse("body {\n  color: red;\n}\n")
  end

  def test_parses_css_with_mixins
    css = <<~CSS
      p { @apply .font-bold; }
    CSS

    output = "p {   font-weight: bold; }\n"
    Deadfire.configuration.asset_registry.register_path("mixin.css", "vendor.css")

    assert_equal output, Deadfire.parse(css, root_path: fixtures_path, filename: "mixin.css")
  end

  focus
  def test_parses_css_with_multiple_mixins_on_different_lines
    css = <<~CSS
      p {
        @apply .font-bold;
        @apply .font-italic;
      }
    CSS

    output = "p {\n    font-weight: bold;\n    font-style: italic;\n}\n"
    Deadfire.configuration.asset_registry.register_path("mixin.css", "vendor.css")

    assert_equal output, Deadfire.parse(css, root_path: fixtures_path, filename: "mixin.css")
  end

  def test_deadfire_parses_with_options
    assert_equal ".test_css_1 {padding:1rem;}body {color:red;}", Deadfire.parse("/*test*/@import \"test_1.css\"; body {\n  color: red;\n}\n", root_path: fixtures_path, compressed: true)
    assert Deadfire.configuration.compressed
  end
end
