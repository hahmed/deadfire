# frozen_string_literal: true

require 'stringio'

module Deadfire
  class Parser
    NEWLINE = "\n"
    OPENING_SELECTOR_PATTERN  = /\..*\{/
    OPENING_SELECTOR_PATTERN2 = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/
    ROOT_SELECTOR_PATTERN     = ":root {"
    IMPORT_SELECTOR_PATTERN   = "@import"
    APPLY_SELECTOR_PATTERN    = "@apply"

    def self.call(options)
      new(options).call
    end

    attr_reader :output

    def initialize(content, options = {})
      @buffer   = StringIO.new(content)
      @filename = options[:filename]
      @output   = StringIO.new
      @lineno   = 0
      @imports  = []
    end

    def call
      while ! @buffer.eof?
        line = @buffer.gets
        if Comment.match?(line)
          Comment.write(@buffer, line, @output)
        else
          @output.write(process_line(line))
        end
      end

      @output.string
    end

    private

      def process_line(line)
        if line.include?(IMPORT_SELECTOR_PATTERN)
          import_path = Import.resolve_import_path(line, @buffer.lineno)
          if @imports.include?(import_path)
            raise DuplicateImportException.new(import_path, @lineno)
          end
          @imports << import_path
          Import.resolve(import_path) # make this async and insert an empty line where we will add the imported css
        elsif line.include?(APPLY_SELECTOR_PATTERN)
          Apply.resolve(line, @buffer.lineno)
        elsif line.include?(ROOT_SELECTOR_PATTERN)
          Mixin.resolve(@buffer, line, @buffer.lineno)
        else
          line
        end
      end
  end
end
