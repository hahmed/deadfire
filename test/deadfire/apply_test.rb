require "test_helper"

class ApplyTest < Minitest::Test
  def setup
    Deadfire::Apply.cached_mixins = {}
  end

  def teardown
    Deadfire::Apply.cached_mixins = {}
  end

  def test_apply_raises_when_no_mixins
    assert_raises Deadfire::EarlyApplyException do
      Deadfire::Apply.resolve("@apply --padding-sm;", 0)
    end
  end

  def test_single_mixin_output_is_correct
    # TODO: we may drop this test too, because it's actually a function?
    Deadfire::Apply.cached_mixins["--padding-sm"] = {"padding": "2px"}

    assert_equal "padding: 2px;", Deadfire::Apply.resolve("@apply --padding-sm", 0)
  end

  def test_multiple_mixins_output_are_correct
    Deadfire::Apply.cached_mixins["--text-red"] = { "font-color": "red"}
    Deadfire::Apply.cached_mixins["--margin-sm"]  = { "margin": "2px"}

    assert_includes "margin: 2px;\nfont-color: red;", Deadfire::Apply.resolve("@apply --margin-sm --text-red;", 0)
  end
end