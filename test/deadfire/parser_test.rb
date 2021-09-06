require "test_helper"

class ParserTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
  end

  def teardown
    Deadfire.reset
  end

  def test_simple_css_outputs_correctly
    output = <<~OUTPUT
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output.chomp, Deadfire::Parser.call(css_input("test_1.css"))
  end

  def test_import_parses_correctly
    output = <<~OUTPUT
    .test_css_1 {
      padding: 1rem;
    }
    .app_css {
      margin: 1rem;
    }
    OUTPUT

    assert_equal output.chomp, Deadfire::Parser.call(css_input("application.css"))
  end

  def test_early_apply_raises_error_when_mixins_not_defined
    assert_raises Deadfire::EarlyApplyException do
      Deadfire::Parser.call(css_input("early_apply_error.css"))
    end
  end

  def test_custom_mixin_parses_correctly
    output = <<~OUTPUT
    :root {
      --main-color: hotpink;
      --admin-header-padding: 5px 42px;
    }
    OUTPUT

    assert_equal output.chomp, Deadfire::Parser.call(css_input("custom_mixins.css"))
    assert Deadfire::Apply.cached_mixins.include?("--bg-header")
    output = {"color"=>"red", "padding"=>"4px"}
    assert_equal output, Deadfire::Apply.cached_mixins["--bg-header"]
  end

  def test_inline_comment_outputs_correctly
    output = <<~OUTPUT
      .test_css_1 {
        padding: 1rem; /* comment */
      }
    OUTPUT

    assert_equal output, Deadfire::Parser.call(output)
  end

  def test_top_comment_outputs_correctly
    output = <<~OUTPUT
      /* comment */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, Deadfire::Parser.call(output)
  end

  def test_multiline_comment_outputs_correctly
    output = <<~OUTPUT
      /* comment
      on
      multlines */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, Deadfire::Parser.call(output)
  end

  def test_commented_import_outputs_correctly
    output = <<~OUTPUT
      /* comment
      @import "test_1.css";
      multlines */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, Deadfire::Parser.call(output)
  end

  private

    def css_input(filename)
      file = File.new(File.join(fixtures_path, filename))
      file.read
    end
end
