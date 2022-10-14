# frozen_string_literal: true
module Deadfire
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
    OPENING_SELECTOR_PATTERN_OTHER  = /\..*\{/
    IMPORT_SELECTOR = "@import"
    CSS_FILE_EXTENSION = ".css"
    APPLY_SELECTOR = "@apply"
    NEWLINE = "\n"

    def self.parse(content, options = {})
      new(content, options).parse
    end

    attr_reader :output

    def initialize(content, options = {})
      @content  = content
      @filename = options[:filename]
      @output   = []
      @imports  = []
    end

    def buffer
      @buffer ||= CssBuffer.new(@content)
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
        if line.include? ROOT_SELECTOR
          @output << Line.new(line, @line_number)
        end

        while !@end_tag && line = @buffer.gets
          if line =~ OPENING_SELECTOR_PATTERN
            @output_current_line = false
            name = extract_mixin_name(line)
            properties = extract_properties_from_mixin(@buffer, line)
            Parser.cached_mixins[name] = properties
          elsif line =~ CLOSING_SELECTOR_PATTERN
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
        while line !~ CLOSING_SELECTOR_PATTERN && !buffer.eof?
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
      attr_accessor :import_path

      def initialize(content, lineno)
        super
        @import_path = self.class.resolve_import_path(content, lineno)
      end

      def parse
        Parser.new(File.read(import_path), filename: import_path).parse
      end

      class << self
        def resolve_import_path(line, lineno = 0)
          path = normalize_import_path(line)
          unless path.end_with?(Parser::CSS_FILE_EXTENSION)
            path += Parser::CSS_FILE_EXTENSION
          end
          import_path = File.join(Deadfire.configuration.root_path, path)

          unless File.exist?(import_path)
            raise Deadfire::ImportException.new(import_path, lineno)
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
      end
    end

    class Apply < Line
      def initialize(...)
        super
        @current_line = @content.dup
        @space  = " "
        @space_counter = 0
        @import_start_tag = "@"
        @output = []
      end

      def parse
        raise Deadfire::EarlyApplyException.new(@content, @lineno) if Parser.cached_mixins.empty?
  
        @current_line.each_char do |char|
          break if char == @import_start_tag
          @space_counter += 1
        end
  
        @current_line.split(" ").each do |css|
          next if css.include?(APPLY_SELECTOR)
          css.gsub!(";", "")
          
          fetch_cached_mixin(css).each_pair do |key, value|
            @output << "#{@space * @space_counter}#{key}: #{value};"
          end
        end
        @output
      end

      private

      # find css class key/val from hash, otherwise throw because the mixin is not defined
      def fetch_cached_mixin(key)
        raise Deadfire::EarlyApplyException.new(key, @lineno) unless Parser.cached_mixins.include?(key)

        Parser.cached_mixins[key]
      end
    end

    class Nesting < Line
      attr_accessor :block_names

      def initialize(content, lineno, buffer, output)
        super(content, lineno)
        @buffer = buffer
        @output = output
        @block_names = []
        @nested_level = 0
      end

      def parse
        line = content.dup.strip
        @block_names << find_block_name(@output, @lineno)
        tmp = []
        
        add_end_block_when_no_end_block_on_prev_line(arr: tmp)
        while @nested_level > 0 || !@buffer.eof?
          spaces = calculate_spaces_to_add(line)
          if line.start_with?(NEST_SELECTOR)
            add_end_block_when_no_end_block_on_prev_line(arr: tmp) if @nested_level > 0
            add_selector_to_block_name(line)
            @nested_level += 1
            tmp << rewrite_line(spaces, line, @block_names[0...-1].join(" "))
            remove_last_block_name_entry if line.end_with?(END_BLOCK_CHAR)
          else
            remove_last_block_name_entry if line.end_with?(END_BLOCK_CHAR)
            tmp << "#{spaces}#{line.lstrip}"
          end

          line = @buffer.gets

          if line.nil? || @buffer.eof? || line.empty?
            break
          else
            line.strip!
          end
        end

        tmp.pop if tmp[-1] == END_BLOCK_CHAR
        tmp.join("\n")
      end

      private

      def remove_last_block_name_entry
        @nested_level -= 1
        @block_names.pop
      end

      def add_selector_to_block_name(line)
        line = extract_selector(line)
        line = line_without_nested_block(line)
        @block_names << line unless @block_names.include?(line)
      end

      def add_end_block_when_no_end_block_on_prev_line(arr: @output)
        unless arr[-1]&.strip&.end_with?("}")
          arr << "}"
        end
      end

      def calculate_spaces_to_add(line)
        unless line =~ OPENING_SELECTOR_PATTERN || line =~ CLOSING_SELECTOR_PATTERN
          "  "
        else
          ""
        end
      end
  
      def extract_selector(line)
        line.split(START_BLOCK_CHAR).first.strip
      end

      def line_without_nested_block(line)
        line.split(NEST_SELECTOR).last.strip
      end
  
      def rewrite_line(spaces, line, selector)
        case number_of_selectors_in(line)
        when 0
          line
        when 1
          "#{spaces}#{line.lstrip.gsub("&", selector)}"
        else
          line.strip.each_char.map do |s|
            if s == NEST_SELECTOR
              selector
            else
              s
            end
          end.join
        end
      end
  
      def number_of_selectors_in(line)
        line.split.count do |s|
          # break if s == "{" # early exit, no need to read every char
          s.start_with?(NEST_SELECTOR)
        end
      end
  
      def find_block_name(output, lineno = nil)
        lineno = output.size unless lineno
        if lineno < 0
          raise "Cannot find block name"
        end

        line = output[lineno]
  
        if line.to_s =~ OPENING_SELECTOR_PATTERN
          extract_selector(line)
        else
          find_block_name(output, lineno - 1)
        end
      end
    end

    def parse
      while ! buffer.eof?
        process_line(buffer.readline)
      end

      @output << NEWLINE

      @output.join
    end

    private

    # this method returns void, and modifies the output array directly
    def process_line(line)
      if line.strip.start_with?("/*")
        handle_comment(line)
      elsif line.strip.start_with?("@import")
        handle_import(line)
      elsif line.strip.start_with?(":root {")
        handle_mixins(line)
      elsif line.strip.start_with?("@apply") # or line.include?("@apply")
        handle_apply(line)
      elsif line.strip.start_with?("&")
        handle_nestings(line)
      else
        @output << line
      end
    end

    def keep_comments?
      Deadfire.configuration.keep_comments
    end

    def handle_comment(line)
      @output << Line.new(line, buffer.lineno) if keep_comments?

      while ! line.include?("*/") && ! buffer.eof?
        line = buffer.gets
        @output << Line.new(line, buffer.lineno) if keep_comments?
      end
    end

    def handle_import(line)
      import = Import.new(line, buffer.lineno)

      if self.class.import_path_cache.include?(import.import_path)
        raise DuplicateImportException.new(import.import_path, buffer.lineno)
      end

      self.class.import_path_cache << import.import_path

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

    def handle_nestings(line)      
      nesting = Nesting.new(line, buffer.lineno, buffer, @output)
      @output << nesting.parse
    end
  end
end
