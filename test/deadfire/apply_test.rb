require "test_helper"

class ApplyTest < Minitest::Test
  def test_simple_apply
    input = <<~INPUT
      .p-2 {
        padding: 0.5rem;
      }
      .btn { 
        @apply p-2; 
      }
    INPUT

    output = <<~OUTPUT
      .p-2 {
        padding: 0.5rem;
      }
      .btn {
        padding: 0.5rem;
      }
    OUTPUT

    assert_equal output, Deadfire::Apply.rework(input)
  end
end