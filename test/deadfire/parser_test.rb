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

    assert_equal output.chomp, Deadfire::Parser.call(options("test_1.css"))
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

    assert_equal output.chomp, Deadfire::Parser.call(options("application.css"))
  end

  def test_early_apply_raises_error_when_mixins_not_defined
    assert_raises Deadfire::EarlyApplyException do
      Deadfire::Parser.call(options("early_apply_error.css"))
    end
  end

  private

    def options(filename)
      {
        filename: filename,
        input: css_input(filename)
      }
    end

    def css_input(filename)
      file = File.new(File.join(fixtures_path, filename))
      file.read
    end
end
