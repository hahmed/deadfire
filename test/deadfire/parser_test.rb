require "test_helper"

class ParserTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Parser.cached_mixins = {}
    Deadfire::Parser.import_path_cache = []
  end

  def teardown
    Deadfire.reset
    Deadfire::Parser.cached_mixins = {}
    Deadfire::Parser.import_path_cache = []
  end

  def test_simple_css_outputs_correctly
    output = <<~OUTPUT
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, css_import_content("test_1.css")
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

    assert_equal output, css_import_content("application.css")
  end

  def test_early_apply_raises_error_when_mixins_not_defined
    assert_raises Deadfire::EarlyApplyException do
      css_import_content("early_apply_error.css")
    end
  end

  def test_inline_comment_outputs_correctly
    output = <<~OUTPUT
      .test_css_1 {
        padding: 1rem; /* comment */
      }
    OUTPUT

    assert_equal output, transform(output)
  end

  def test_top_comment_outputs_correctly
    output = <<~OUTPUT
      /* comment */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, transform(output)
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

    assert_equal output, transform(output)
  end

  def test_commented_import_outputs_correctly
    output = <<~OUTPUT
      /* comment
      @import "test_1.css";
      multilines */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, transform(output)
  end

  def test_multiline_comment_is_removed_when_config_setting_is_true
    Deadfire.configuration.keep_comments = false
    input = <<~OUTPUT
      /* comment
      @import "test_1.css";
      multilines */
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT
    output = <<~OUTPUT
      .test_css_1 {
        padding: 1rem;
      }
    OUTPUT

    assert_equal output, transform(output)
  end

  def test_comment_without_closing_tag_has_errors
    output = <<~OUTPUT
    /* comment
    OUTPUT

    parser = Deadfire::Parser.new(output)
    assert_equal output, parser.parse.chomp
    assert parser.errors?
    assert_includes parser.errors_list.errors.first.message, "line: 1: Unclosed comment error"
  end

  def test_mixin_outputs_correctly
    output = <<~OUTPUT
      :root {
      }

      .title {
        font-weight: bold;}
    OUTPUT

    assert_equal output, transform(<<~INPUT)
      :root {
        --font-bold: {
          font-weight: bold;
        }
      }

      .title {
        @apply --font-bold;
      }
    INPUT
  end

  def test_import_with_mixins_parses_correctly
    # TODO: fix empty lines in mixin, maybe remove entire root tag if no mixins?
    output = <<~OUTPUT
    .hero-title {
      font-weight: bold;}

    .title {
      font-weight: bold;
      padding: 2px 0;}
    OUTPUT

    assert_equal output, css_import_content("complete.css")
  end

  # mixins

  def test_root_with_custom_properties_parses_correctly
    css = <<~CSS
      :root {
        .test_css: padding: 1rem;
      }
    CSS

    assert_equal css, transform(css)
  end

  def test_root_with_vars_parses_correctly
    css = <<~CSS
      :root {
        --test-css: padding: 1rem;
      }
    CSS

    assert_equal css, transform(css)
  end

  def test_multiline_vars_aka_mixin_parses_correctly
    css = <<~CSS
      :root {
        --test-css: {
          padding: 1rem;
        }
      }
    CSS

    assert_equal <<~OUTPUT, transform(css)
    :root {
    }
    OUTPUT
  end

  def test_apply_raises_when_no_mixins
    assert_raises Deadfire::EarlyApplyException do
      transform("@apply --padding-sm;")
    end
  end

  def test_single_mixin_output_is_correct
    # TODO: we may drop this test too, because it's actually a function?
    Deadfire::Parser.cached_mixins["--padding-sm"] = {"padding": "2px"}

    assert_equal "padding: 2px;", transform("@apply --padding-sm")
  end

  def test_multiple_mixins_output_are_correct
    Deadfire::Parser.cached_mixins["--text-red"] = { "font-color": "red"}
    Deadfire::Parser.cached_mixins["--margin-sm"]  = { "margin": "2px"}

    assert_includes "margin: 2px;\nfont-color: red;", transform("@apply --margin-sm --text-red;")
  end

  def test_raises_error_when_invalid_import_location
    assert_raises(Deadfire::ImportException) do
      css_import_content("randomness/test_1")
    end
  end

  def test_basic_import
    assert_equal <<~CSS, css_import_content("test_1")
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_with_extension
    assert_equal <<~CSS, css_import_content("test_1.css")
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_in_admin_directory
    assert_equal <<~CSS, css_import_content("admin/test_3.css")
      .test_css_3 {
        padding: 3rem;
      }
    CSS
  end

  def test_parses_apply_correctly_when_line_ends_with_end_block_char
    css = <<~CSS
    :root {
      --font-bold: {
        font-weight: bold;
      }
    }

    .title {
      @apply --font-bold;}
    CSS

    assert_equal <<~OUTPUT.chomp, transform(css)
    :root {
    }

    .title {
      font-weight: bold;
    }
    OUTPUT
  end

  private

    def transform(css)
      Deadfire::Parser.parse(css).chomp
    end

    def css_import_content(filename)
      normalized_path = Deadfire::FilenameHelper.normalize_path(filename)
      transform("@import \"#{normalized_path}\"")
    end
end
