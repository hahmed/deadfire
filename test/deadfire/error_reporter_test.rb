require "test_helper"

class ErrorReporterTest < Minitest::Test
  def setup
    Deadfire.configuration.root_path = fixtures_path
    # Deadfire::Interpreter.cached_apply_rules = {}
  end

  def teardown
    Deadfire.reset
    # Deadfire::Interpreter.cached_apply_rules = {}
  end

  def test_import_without_ending_semicolon_reports_error
    parser = Deadfire::ParserEngine.new("@import \"application.css\"")
    parser.send(:_parse)
    assert_equal 1, parser.error_reporter.errors.count
    assert_equal "Imports must be terminated correctly with a ';'.", parser.error_reporter.errors.first.message
  end

  def test_when_mixin_undefined_error_is_reported
    parser = Deadfire::ParserEngine.new(".header { @apply .bg-header; }")
    parser.parse
    assert_equal 1, parser.error_reporter.errors.count
    assert_equal "Mixin .bg-header not found", parser.error_reporter.errors.first.message
  end

  def test_content_of_imports_are_parsed_and_report_error_when_using_undefined_mixin
    parser = Deadfire::ParserEngine.new(import("early_apply_error.css"))
    parser.parse
    assert_equal 1, parser.error_reporter.errors.count
    assert_equal "Mixin .padding-1 not found", parser.error_reporter.errors.first.message
  end

  def test_comment_without_closing_tag_has_errors
    css = "/* comment"

    parser = Deadfire::ParserEngine.new(css)
    parser.parse
    assert parser.errors?
    assert_includes parser.error_reporter.errors.first.message, "Unterminated comment on line 1"
  end
end
