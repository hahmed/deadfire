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
    BEGIN_COMMENT_PATTERN     = "/*"
    END_COMMENT_PATTERN       = "*/"
    CSS_FILE_EXTENSION = ".css"

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

    class << self
      # TODO: there may be additional directories to traverse from the config e.g. node_modules?
      def resolve_import_path(current_line, lineno: 0)
        path = normalize_import_path(current_line)
        unless path.end_with?(CSS_FILE_EXTENSION)
          path += CSS_FILE_EXTENSION
        end
        import_path = File.join(Deadfire.configuration.root_path, path)

        unless File.exist?(import_path)
          raise ImportException.new(import_path, lineno)
        end

        import_path
      end
      
      def normalize_import_path(line)
        path = line.split.last
        path.gsub!("\"", "")
        path.gsub!("\'", "")
        path.gsub!(";", "")
        path
      end
      
      def parse_import_path(line)
        path   = normalize_import_path(line)
        output = StringIO.new
        buffer = StringIO.new(File.read(path))

        while ! buffer.eof?
          current_line = buffer.gets
          if match_comment?(current_line)
            read_comment_block(current_line)
          elsif current_line.include?(Parser::APPLY_SELECTOR_PATTERN)
            output.write Apply.resolve(current_line, buffer.lineno)
          else
            output.write current_line
          end
        end

        output.string
      end

      def match_comment?(line)
        line.start_with?(BEGIN_COMMENT_PATTERN)
      end
  end

    private

      def process_line(line)
        if self.class.match_comment?(line)
          read_comment_block(line)
        elsif line.include?(IMPORT_SELECTOR_PATTERN)
          import_path = self.class.resolve_import_path(line, lineno: @buffer.lineno)
          if @imports.include?(import_path)
            raise DuplicateImportException.new(import_path, @lineno)
          end
          @imports << import_path
          self.class.parse_import_path(import_path) # make this async and insert an empty line where we will add the imported css
        elsif line.include?(ROOT_SELECTOR_PATTERN)
          Mixin.resolve(@buffer, line, @buffer.lineno)
        elsif line.include?(APPLY_SELECTOR_PATTERN)
          Apply.resolve(line, @buffer.lineno)
        elsif Deadfire::Nest.match?(line)
          Nesting.resolve(@buffer, @output, line, @buffer.lineno)
        else
          line
        end
      end

      def read_comment_block(line)
        @output << line

        unless line.include?(END_COMMENT_PATTERN)
          while ! line.include?(END_COMMENT_PATTERN) && ! @buffer.eof?
            line = @buffer.gets
            @output << line
          end
        end
      end
    end
end
