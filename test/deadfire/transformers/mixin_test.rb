# ruby -Itest test/deadfire/transformers/mixin_test.rb -n test
require "test_helper"

module Transformers
  class MixinTest < Minitest::Test
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

    private

    def transform(content)
      mixin = Deadfire::Transformers::Mixin.new
      css_buffer = buffer(content: content)
      output = []
      content = []

      css_buffer.each_line do |line|
        if mixin.matches? line
          content << mixin.transform(line, css_buffer, output)
        end
      end

      content.join
    end
  end
end