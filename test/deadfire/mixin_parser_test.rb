require "test_helper"

class MixinParserTest < Minitest::Test
  def setup
    @mixin_parser = Deadfire::MixinParser.new
  end

  def test_utility_selector_gets_cached
    mixins = parse(".test_css_1 {padding:1rem;}")
    assert_equal 1, mixins.size
    assert mixins.key(".test_css_1")
  end

  def test_psuedo_selector_does_not_get_cached
    assert_equal 0, parse("a:hover {padding:1rem;}").size
  end

  def test_id_selector_does_not_get_cached
    assert_equal 0, parse("#my_nav {padding:1rem;}").size
  end

  def test_element_selector_does_not_get_cached
    assert_equal 0, parse("p {padding:1rem;}").size
  end

  def test_attribute_selector_does_not_get_cached
    assert_equal 0, parse("input[type=\"text\"] {padding:1rem;}").size
  end

  def test_nested_utility_selector_does_not_get_cached
    assert_equal 0, parse("::root { .nav{padding:1rem;} }").size
  end

  def test_parses_nested_media_query_correctly_and_block_is_not_cached
    css = <<~CSS
      @media screen and (min-width: 480px) {
        .test_css_1 {padding:1rem;}
      }
    CSS

    assert_equal 0, parse(css).size
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

    assert_equal 0, parse(css).size
  end

  private

  def parse(css)
    ast = ast_tree(css)
    ast.statements.each do |node|
      @mixin_parser.interpret(node)
    end
    @mixin_parser.mixins
  end

  def ast_tree(css)
    parser = Deadfire::ParserEngine.new(css)
    parser.send(:_parse)
  end
end