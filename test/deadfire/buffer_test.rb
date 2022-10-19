require "test_helper"

class BufferTest < Minitest::Test
  def test_can_read_from_buffer
    buffer = Deadfire::CssBuffer.new("body { color: red; }")
    assert_equal "body { color: red; }", buffer.gets
    assert buffer.eof?
  end

  def test_read_from_buffer_and_skip_buffer_is_not_eof
    buffer = Deadfire::CssBuffer.new("body { color: red; }")
    assert_equal "body { color: red; }", buffer.gets(skip_buffer: true)
    refute buffer.eof?
  end
end
