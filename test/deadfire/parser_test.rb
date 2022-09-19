require "test_helper"

class ParserTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
    Deadfire::Parser.cached_mixins = {}
  end

  def teardown
    Deadfire.reset
    Deadfire::Parser.cached_mixins = {}
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
    assert Deadfire::Transformers::Apply.cached_mixins.include?("--bg-header")
    output = {"color"=>"red", "padding"=>"4px"}
    assert_equal output, Deadfire::Transformers::Apply.cached_mixins["--bg-header"]
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
    Deadfire::Transformers::Apply.cached_mixins["--padding-sm"] = {"padding": "2px"}

    assert_equal "padding: 2px;", transform("@apply --padding-sm")
  end

  def test_multiple_mixins_output_are_correct
    Deadfire::Transformers::Apply.cached_mixins["--text-red"] = { "font-color": "red"}
    Deadfire::Transformers::Apply.cached_mixins["--margin-sm"]  = { "margin": "2px"}

    assert_includes "margin: 2px;\nfont-color: red;", transform("@apply --margin-sm --text-red;")
  end

  def test_nest_selector_used_on_its_own
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo > .bar { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      & > .bar { color: red; }
    }
    INPUT
  end

  def test_nest_in_compound_selector
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo.bar { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      &.bar { color: red; }
    }
    INPUT
  end

  def test_multiple_selectors_unfold_when_correct_starting_selector_is_used
    skip

    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo.bar { color: red; }
    CSS

    assert_equal output, parse_input(<<~INPUT)
    .foo, .bar {
      .foo, .bar { color: blue; }
      :is(.foo, .bar) + .baz,
      :is(.foo, .bar).qux { color: red; }
    }
    INPUT
  end

  def test_selectors_can_be_used_multiple_times_in_single_selector
    output = <<~CSS
    .foo {
      color: blue;
    }
    .foo .bar .foo .baz .foo .qux { color: red; }
    CSS

    assert_includes output, parse_input(<<~INPUT)
    .foo {
      color: blue;
      & .bar & .baz & .qux { color: red; }
    }
    INPUT
  end

  def test_complete_nesting_unfolds_correctly
    output = <<~CSS
    table.colortable {
    }
    table.colortable th {
      text-align:center;
      background:black;
      color:white;
    }
    table.colortable td {
      text-align:center;
    }
    table.colortable td.c {
      text-transform:uppercase;
    }
    table.colortable td:first-child, table.colortable td:first-child+td {
      border:1px solid black;
    }
    CSS

    assert_includes parse_input(<<~INPUT), output
    table.colortable {
      & th {
        text-align:center;
        background:black;
        color:white;
      }
      & td {
        text-align:center;
        &.c { text-transform:uppercase }
        &:first-child, &:first-child + td { border:1px solid black }
      }
    }
    INPUT
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

  private

    def transform(css)
      Deadfire::Parser.new(css).parse
    end

    def css_input(filename)
      file = File.read(File.join(fixtures_path, filename))
      Deadfire::Parser.call file
    end

    def css_import_content(filename)
      normalized_path = Deadfire::Parser.resolve_import_path(path)
      Deadfire::Parser.parse_import_path("@import \"#{normalized_path}\"")
    end
end
