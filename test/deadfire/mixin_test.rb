require "test_helper"

class MixinTest < Minitest::Test
  def test_root_with_custom_properties_parses_correctly
    css = <<~CSS
      :root {
        .test_css: padding: 1rem;
      }
    CSS

    mixin = Deadfire::Mixin.new(StringIO.new(css))
    assert_equal css, mixin.resolve
  end

  def test_root_with_vars_parses_correctly
    css = <<~CSS
      :root {
        --test-css: padding: 1rem;
      }
    CSS

    mixin = Deadfire::Mixin.new(StringIO.new(css))
    assert_equal css, mixin.resolve
  end

  def test_multiline_vars_parses_correctly
    css = <<~CSS
      :root {
        --test-css: {
          padding: 1rem;
        }
      }
    CSS

    mixin = Deadfire::Mixin.new(StringIO.new(css))
    assert_equal <<~OUTPUT, mixin.resolve
    :root {
    }
    OUTPUT
  end
end