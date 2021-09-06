# frozen_string_literal: true

module Deadfire
  class DirectoryNotFoundError < StandardError; end
  class Error < StandardError; end
  class FileNotFoundError < StandardError; end

  class EarlyApplyException < StandardError
    def initialize(input = "", lineno = "")
      msg = if input
        "Error with input: `#{input}` line: #{lineno}"
      else
        "Apply called too early in css. There are no mixins defined."
      end

      super(msg)
    end
  end
end