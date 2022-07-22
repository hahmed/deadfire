require "test_helper"

module Transformers
  class ApplyTest < Minitest::Test
    def setup
      Deadfire::Transformers::Apply.cached_mixins = {}
    end

    def teardown
      Deadfire::Transformers::Apply.cached_mixins = {}
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

    private

    def transform(css)
      Deadfire::Transformers::Apply.new.transform(css, buffer, 0, "")
    end
  end
end