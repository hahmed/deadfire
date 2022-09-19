# frozen_string_literal: true
# https://www.w3.org/TR/css-syntax-3/#consume-token
module Deadfire
  class Parser
    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = {} }

    ROOT_SELECTOR = ":root {"
    OPENING_SELECTOR_PATTERN = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/
    NEST_SELECTOR = "&"
    START_BLOCK_CHAR = "{"
    END_BLOCK_CHAR = "}"
    OPENING_SELECTOR_PATTERN_OTHER  = /\..*\{/
    IMPORT_SELECTOR = "@import"
    CSS_FILE_EXTENSION = ".css"

    def self.call(options)
      new(options).parse
    end

    attr_reader :output

    def initialize(content, options = {})
      @content  = content
      @filename = options[:filename]
      @keep_comments = options[:keep_comments]
      @output   = []
      @imports  = []
    end

    def buffer
      @buffer ||= CssBuffer.new(@content)
    end

    def parse
      # preprocess

      # lex and parse in one pass
      while ! buffer.eof?
        process_line(buffer.readline)
      end

      # run custom transformers/plugins

      # finalize
      @output << "\n"
      @output.join
    end

    private

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
      @keep_comments ||= true
    end

    def handle_comment(line)
      @output << line if keep_comments?

      while ! line.include?("*/") && ! buffer.eof?
        line = buffer.gets
        @output << line if keep_comments?
      end
    end

    def handle_import(line)
      import_path = self.class.resolve_import_path(line, lineno: buffer.lineno)
      if self.class.import_path_cache.include?(import_path)
        raise DuplicateImportException.new(import_path, @buffer.lineno)
      end
      self.class.import_path_cache << import_path
      self.class.parse_import_path(import_path) # make this async and insert an empty line where we will add the imported css
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
          raise Deadfire::ImportException.new(import_path, buffer.lineno)
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
        parser = Parser.new(File.read(path), filename: path)
        # TODO: 
        # - improve this code
        # - decide on how many levels of imports we want to allow
        # - make async??
        parser.call
      end
    end

    def handle_apply(line)
      current_line = line.dup
      output = []
      space  = " "
      space_counter = 0
      import_start_tag = "@"

      raise Deadfire::EarlyApplyException.new(buffer, buffer.lineno) if Parser.cached_mixins.empty?

      current_line.each_char do |char|
        break if char == import_start_tag
        space_counter += 1
      end

      current_line.split(" ").each do |css|
        next if css.include?(SELECTOR)
        css.gsub!(";", "")
        
        fetch_cached_mixin(css, buffer.lineno).each_pair do |key, value|
          output << "#{space * space_counter}#{key}: #{value};"
        end
      end

      output.join(NEWLINE)
    end

     # find css class key/val from hash, otherwise throw because the mixin is not defined
     def fetch_cached_mixin(key, lineno)
      raise Deadfire::EarlyApplyException.new(key, lineno) unless Parser.cached_mixins.include?(key)

      Apply.cached_mixins[key]
    end

    def handle_mixins(line)
      end_tag = false
      output_line = true
      content = []

      # create a var, and store output here?
      # or use the output instead?

      # skip if first line is root tag
      if line.include? ROOT_SELECTOR
        content << line
        line = buffer.gets
      end
      
      while !end_tag
        if line =~ OPENING_SELECTOR_PATTERN
          output_line = false
          name = extract_mixin_name(line)
          properties = extract_properties_from_mixin(buffer, line)
          Parser.cached_mixins[name] = properties
        elsif line =~ CLOSING_SELECTOR_PATTERN
          end_tag = true
        end

        content << line if output_line

        if end_tag || buffer.eof?
          return content
        end

        line = buffer.gets
        output_line = true
      end

      @output << content.join
    end

    def extract_mixin_name(line)
      line.tr("{", "").tr(".", "").tr(":", "").strip
    end

    # TODO: handle css properties that have hanging comments e.g. color: red;  /* Set text color to red */
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

    def handle_nestings(line)
      line = buffer.gets unless line
      @output << "}\n"
      block_name = []
      found_end_for_current_nested_block = false
      lineno = @output.size
      block_name << find_block_name(@output, lineno)

      while ! buffer.eof?
        if line.strip.start_with?(NEST_SELECTOR)
          spaces = calculate_spaces_to_add(line)
          @output << "#{spaces}#{rewrite_line(line.strip, block_name.join(" "))}\n"
        else
          @output << line
        end

        lineno += 1
        if line.strip.end_with?(END_BLOCK_CHAR)
          break
        end
        line = buffer.gets
      end

      # if there is an ending block after the nested content, that can be ignored
      line = buffer.gets
      unless line.strip.end_with?(END_BLOCK_CHAR)
        buffer.ungetc(line)
      end

      nil
    end

    def calculate_spaces_to_add(line)
      unless line =~ OPENING_SELECTOR_PATTERN2 || line =~ CLOSING_SELECTOR_PATTERN
        "  "
      else
        ""
      end
    end

    def extract_selector(line)
      line.tr(START_BLOCK_CHAR, "").strip
    end

    def rewrite_line(line, selector)
      case number_of_selectors_in(line)
      when 0
        line
      when 1
        "#{selector} { #{extract_selector(line)} }"
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
        break if s == "{" # early exit, no need to read every char
        s.start_with?(NEST_SELECTOR)
      end
    end

    def find_block_name(output, lineno = nil)
      lineno = output.size unless lineno
      line = output[lineno]

      if line.to_s =~ OPENING_SELECTOR_PATTERN2
        extract_selector(line)
      else
        find_block_name(output, lineno - 1)
      end
    end
  end
end
