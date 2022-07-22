# frozen_string_literal: true
require "stringio"

module Deadfire
  class CssBuffer < StringIO
    def initialize(content)
      super(content)
    end

    # def readline
    #   @buffer.readline
    # end

    # def readlines(n)
    #   @buffer.readlines(n)
    # end

    # def unread(line)
    #   @buffer.unread(line)
    # end

    # def unread_lines(lines)
    #   @buffer.unread_lines(lines)
    # end

    # def each(&block)
    #   @buffer.each(&block)
    # end

    # def each_line(&block)
    #   @buffer.each_line(&block)
    # end
  end
end