# frozen_string_literal: true

module Deadfire
  class DirectoryNotFoundError < StandardError; end
  class Error < StandardError; end

  class DuplicateImportException < StandardError
    def initialize(filename = "", lineno = "")
      msg = if filename
        "Duplicate import found: `#{filename}` line: #{lineno}"
      else
        "Duplicate import."
      end

      super(msg)
    end
  end

  class ImportException < StandardError
    def initialize(filename = "", lineno = "")
      msg = if filename
        "Error importing file: `#{filename}` line: #{lineno}"
      else
        "Error importing file."
      end

      super(msg)
    end
  end

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

  class SyntaxError < StandardError
    def initialize(message = "", lineno = "", original_line = "")
      msg = if message
        "#{original_line}\nline: #{lineno}: #{message}"
      else
        "Syntax "
      end

      super(msg)
    end
  end

  class ErrorsList
    attr_reader :errors

    def initialize
      @errors = []
    end

    def add(message:, lineno:, original_line:)
      @errors << SyntaxError.new(message, lineno, original_line)
    end

    def empty?
      @errors.empty?
    end
  end
end