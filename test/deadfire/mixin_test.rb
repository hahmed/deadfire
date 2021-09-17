require "test_helper"

class MixinTest < Minitest::Test
  def test_root_with_custom_properties_parses_correctly
    css = <<~CSS
      :root {
        .test_css: padding: 1rem;
      }
    CSS

    assert_equal css, Deadfire::Mixin.resolve(StringIO.new(css))
  end

  def test_root_with_vars_parses_correctly
    css = <<~CSS
      :root {
        --test-css: padding: 1rem;
      }
    CSS

    assert_equal css, Deadfire::Mixin.resolve(StringIO.new(css))
  end

  def test_multiline_vars_parses_correctly
    css = <<~CSS
      :root {
        --test-css: {
          padding: 1rem;
        }
      }
    CSS

    assert_equal <<~OUTPUT, Deadfire::Mixin.resolve(StringIO.new(css))
    :root {
    }
    OUTPUT
  end
end