# frozen_string_literal: true
require "stringio"

module Deadfire
  class CssBuffer
    attr_reader :lineno, :buffer

    def initialize(content)
      @content = StringIO.new(content)
      @buffer = []
      @lineno = 0
    end

    def gets(skip_buffer: false)
      output = content.gets
      if output && !skip_buffer
        buffer << output
      end
      @lineno += 1
      output
    end

    def eof?
      content.eof? && buffer.size == lineno
    end

    private

    attr_reader :content
  end
end
