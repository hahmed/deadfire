require "test_helper"

class ProcessorTest < Minitest::Test
  def test_simple_apply_directive
    skip
    input = <<~INPUT
      .py-2 {
        padding-top: 0.5rem;
        padding-bottom: 0.5rem;
      }

      .btn { 
        @apply py-2; 
      }
    INPUT

    output = <<~OUTPUT
      .btn {
        padding-top: 0.5rem;
        padding-bottom: 0.5rem;
      }
    OUTPUT

    assert_equal output, Deadfire::Processor.run(input)
  end
end
