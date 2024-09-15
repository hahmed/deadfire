require "test_helper"

class AstTest < Minitest::Test
  def test_ast_prints_correctly
    css = <<~CSS
      /* comment */
      .test_css_1 {
        padding: 1rem;
      }

      p { size: 1rem; }
    CSS
    parser = Deadfire::ParserEngine.new(css)
    out, _ = capture_io do
      parser.print_ast
    end

    assert_includes out, "CommentNode"
  end
end