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

    assert_equal output.chomp, css_input("test_1.css")
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

    assert_equal output.chomp, css_input("application.css")
  end

  def test_raises_error_when_invalid_import_location
    assert_raises(Deadfire::ImportException) do
      css_import_content("randomness/test_1")
    end
  end

  def test_basic_import
    assert_equal <<~CSS.strip, css_import_content("test_1")
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_with_extension
    assert_equal <<~CSS.strip, css_import_content("test_1.css")
      .test_css_1 {
        padding: 1rem;
      }
    CSS
  end

  def test_import_in_admin_directory
    assert_equal <<~CSS.strip, css_import_content("admin/test_3.css")
      .test_css_3 {
        padding: 3rem;
      }
    CSS
  end

  def test_parses_import_path_with_double_quotes_correctly
    assert_equal "something", Deadfire::Parser.normalize_import_path("@import \"something\"")
  end

  def test_parses_import_path_with_single_quotes_correctly
    assert_equal "something", Deadfire::Parser.normalize_import_path("@import \'something\'")
  end

  def test_parses_import_path_with_semicolons_correctly
    assert_equal "something", Deadfire::Parser.normalize_import_path("@import \"something\";")
  end

  def test_parses_import_path_with_dirname_correctly
    assert_equal "admin/test3.css", Deadfire::Parser.normalize_import_path("@import \"admin/test3.css\";")
  end

  def test_early_apply_raises_error_when_mixins_not_defined
    assert_raises Deadfire::EarlyApplyException do
      css_input("early_apply_error.css")
    end
  end

  def test_custom_mixin_parses_correctly
    # TODO: we may not support this format, this should be a function
    # that means we can drop this this
    output = <<~OUTPUT
    :root {
      --main-color: hotpink;
      --admin-header-padding: 5px 42px;
    }
    OUTPUT

    assert_equal output.chomp, css_input("custom_mixins.css")
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

  def test_mixin_outputs_correctly
    output = <<~OUTPUT
      :root {
      }

      .title {
        font-weight: bold;}
    OUTPUT

    assert_equal output, Deadfire::Parser.call(<<~INPUT)
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
    :root {



    }

    .hero-title {
      font-weight: bold;}
    .title {
      font-weight: bold;
      padding: 2px 0;}
    OUTPUT

    assert_equal output.chomp, css_input("complete.css")
  end

  private

    def css_input(filename)
      Deadfire::Parser.call File.read(File.join(fixtures_path, filename))
    end

    def css_import_content(path)
      normalized_path = Deadfire::Parser.resolve_import_path(path)
      Deadfire::Parser.parse_import_path("@import \"#{normalized_path}\"")
    end
end
