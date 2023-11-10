# frozen_string_literal: true
module Deadfire
  # NOTE: Legacy parser, will be replaced by ParserEngine
  class Parser
    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = {} }

    singleton_class.attr_accessor :import_path_cache
    self.import_path_cache = []

    ROOT_SELECTOR = ":root {"
    OPENING_SELECTOR_PATTERN = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/
    NEST_SELECTOR = "&"
    START_BLOCK_CHAR = "{"
    END_BLOCK_CHAR = "}"
    IMPORT_SELECTOR = "@import"
    CSS_FILE_EXTENSION = ".css"
    APPLY_SELECTOR = "@apply"
    NEWLINE = "\n"
    OPEN_COMMENT_SELECTOR = "/*"
    CLOSE_COMMENT_SELECTOR = "*/"

    def self.parse(content, options = {})
      new(content, options).parse
    end

    attr_reader :output, :errors_list

    def initialize(content, options = {})
      @content  = content
      @errors_list   = ErrorsList.new
      @filename = options[:filename]
      @output   = []
      @imports  = []
    end

    def buffer
      @content = preprocess
      @buffer ||= CssBuffer.new(@content)
    end

    def parse
      while ! buffer.eof?
        process_line(buffer.gets)
      end

      @output << NEWLINE

      @output.join
    end

    def errors?
      @errors_list.errors.any?
    end

    private

    def preprocess
      @content.gsub(/\r\n?|\f/, "\n").gsub("\u{0000}", "\u{FFFD}")
    end

    # this method returns void, and modifies the output array directly
    def process_line(line)
      if line.strip.start_with?(OPEN_COMMENT_SELECTOR)
        handle_comment(line)
      elsif line.strip.start_with?(IMPORT_SELECTOR)
        handle_import(line)
      elsif line.strip.start_with?(ROOT_SELECTOR)
        handle_mixins(line)
      elsif line.strip.start_with?(APPLY_SELECTOR)
        handle_apply(line)
      else
        @output << line
      end
    end

    def keep_comments?
      Deadfire.configuration.keep_comments
    end

    def handle_comment(line)
      @output << Line.new(line, buffer.lineno) if keep_comments?

      while ! line.include?(CLOSE_COMMENT_SELECTOR) && ! buffer.eof?
        line = buffer.gets
        @output << Line.new(line, buffer.lineno) if keep_comments?
      end

      if buffer.eof?
        @errors_list.add(message: "Unclosed comment error", lineno: buffer.lineno, original_line: line)
      end
    end

    def handle_import(line)
      import = Import.new(line, buffer.lineno)

      # TODO:
      # - decide on how many levels of imports we want to allow
      # - make async??
      @output << import.parse
    end

    def handle_apply(line)
      @apply = Apply.new(line, buffer.lineno)
      @output << @apply.parse.join(NEWLINE)
    end

    def handle_mixins(line)
      @root = Root.new(line, buffer.lineno, buffer)
      @output << @root.parse
    end
  end

  class Line
    attr_accessor :content, :line_number

    def initialize(content, line_number)
      @content = content
      @line_number = line_number
    end

    def to_s
      content
    end
  end

  class Root < Line
    def initialize(content, lineno, buffer)
      super(content, lineno)
      @end_tag = false
      @output_current_line = true
      @output = []
      @buffer = buffer
    end

    def parse
      line = @content
      if line.include? Parser::ROOT_SELECTOR
        @output << Line.new(line, @line_number)
      end

      while !@end_tag && line = @buffer.gets
        if line =~ Parser::OPENING_SELECTOR_PATTERN
          @output_current_line = false
          name = extract_mixin_name(line)
          properties = extract_properties_from_mixin(@buffer, line)
          Parser.cached_mixins[name] = properties
        elsif line =~ Parser::CLOSING_SELECTOR_PATTERN
          @end_tag = true
        end

        @output << Line.new(line, @buffer.lineno) if @output_current_line
        @output_current_line = true
      end

      to_s
    end

    def to_s
      return "" if @output.size <= 1

      @output.map(&:to_s)
    end

    private

    def extract_mixin_name(line)
      line.tr("{", "").tr(".", "").tr(":", "").strip
    end

    def extract_properties_from_mixin(buffer, line)
      properties = {}
      line = buffer.gets # skip opening {
      while line !~ Parser::CLOSING_SELECTOR_PATTERN && !buffer.eof?
        name, value = extract_name_and_values(line)
        properties[name] = value
        line = buffer.gets
      end
      properties
    end

    def extract_name_and_values(line)
      name, value = line.split(":")
      value = value.gsub(";", "")
      [name, value].map(&:strip)
    end
  end

  class Import < Line
    def initialize(...)
      super(...)
    end

    def parse
      import_path = FilenameHelper.resolve_import_path(content, @lineno)

      if Parser.import_path_cache.include?(import_path)
        raise DuplicateImportException.new(import_path, @lineno)
      end

      Parser.import_path_cache << import_path

      Parser.new(File.read(import_path), filename: import_path).parse
    end
  end

  class Apply < Line
    def initialize(...)
      super
      @current_line = @content.dup
      @space  = " "
      @apply_start_char = "@"
      @output = []
    end

    def parse
      raise Deadfire::EarlyApplyException.new(@content, @lineno) if Parser.cached_mixins.empty?

      space_counter = calculate_number_of_spaces
      ends_with_end_block_char = false

      @current_line.split(" ").each do |css|
        next if css.include?(Parser::APPLY_SELECTOR)

        css.gsub!(";", "")
        if css.end_with?(Parser::END_BLOCK_CHAR)
          ends_with_end_block_char = true
          css.gsub!(Parser::END_BLOCK_CHAR, "")
        end

        fetch_cached_mixin(css).each_pair do |key, value|
          @output << "#{@space * space_counter}#{key}: #{value};"
        end
      end
      @output << "#{Parser::END_BLOCK_CHAR}" if ends_with_end_block_char
      @output
    end

    private

    def calculate_number_of_spaces
      space_counter = 0
      @current_line.each_char do |char|
        break if char == @apply_start_char
        space_counter += 1
      end
      space_counter
    end

    # find css class key/val from hash, otherwise throw because the mixin is not defined
    def fetch_cached_mixin(key)
      raise Deadfire::EarlyApplyException.new(key, @lineno) unless Parser.cached_mixins.include?(key)

      Parser.cached_mixins[key]
    end
  end
end
