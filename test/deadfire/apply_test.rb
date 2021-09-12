require "test_helper"

class ApplyTest < Minitest::Test
  def setup
    Deadfire::Apply.cached_mixins = {}
  end

  def teardown
    Deadfire::Apply.cached_mixins = {}
  end

  def test_apply_raises_when_no_mixins
    apply = Deadfire::Apply.new("@apply --padding-sm;", 0)

    assert_raises Deadfire::EarlyApplyException do
      apply.resolve
    end
  end

  def test_single_mixin_output_is_correct
    # TODO: we may drop this test too, because it's actually a function?
    Deadfire::Apply.cached_mixins["--padding-sm"] = {"padding": "2px"}
    apply = Deadfire::Apply.new("@apply --padding-sm", 0)

    assert_includes "  padding: 2px;", apply.resolve
  end

  def test_multiple_mixins_output_are_correct
    Deadfire::Apply.cached_mixins["--text-red"] = { "font-color": "red"}
    Deadfire::Apply.cached_mixins["--margin-sm"]  = { "margin": "2px"}
    apply = Deadfire::Apply.new("@apply --margin-sm --text-red;", 0)

    assert_includes "  margin: 2px;\n  font-color: red;", apply.resolve
  end
end