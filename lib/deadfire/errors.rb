# frozen_string_literal: true

module Deadfire
  class DirectoryNotFoundError < StandardError; end

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
end
