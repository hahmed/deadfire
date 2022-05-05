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
    NESTING_SELECTOR_PATTERN  = "&"

    def self.call(options)
      new(options).call
    end

    attr_reader :output

    def initialize(content, options = {})
      @buffer   = StringIO.new(content)
      @filename = options[:filename]
      @output   = []
      @lineno   = 0
      @imports  = []
      @additional_css_blocks = []
      @css_block_start_pos = nil
    end

    def call
      while ! @buffer.eof?
        @output << process_line(@buffer.readline)
        @lineno += 1
      end

      @output.join
    end

    private

      def process_line(line)
        if Comment.match?(line)
          Comment.write(@buffer, line, @output)
        elsif line.include?(IMPORT_SELECTOR_PATTERN)
          import_path = Import.resolve_import_path(line, @buffer.lineno)
          if @imports.include?(import_path)
            raise DuplicateImportException.new(import_path, @lineno)
          end
          @imports << import_path
          Import.resolve(import_path) # make this async and insert an empty line where we will add the imported css
        elsif line.include?(ROOT_SELECTOR_PATTERN)
          Mixin.resolve(@buffer, line, @buffer.lineno)
        elsif line.include?(APPLY_SELECTOR_PATTERN)
          Apply.resolve(line, @buffer.lineno)
        elsif Deadfire::Nest.match?(line)
          # NOTE:
          # nesting blocks could have @apply blocks
          # if end of css block, add any additional nestings after then clear array
          # lets assert a few things, the nesting block is the last part of the css block
          # another nest block can appear but can there be more css key/vals after the nesting block??

          # do not write nesting line, instead read the entire nesting block
          Nesting.resolve(@buffer, @output, line, @buffer.lineno)
        else
          line
        end
      end
  end
end
