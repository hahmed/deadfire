# frozen_string_literal: true

module Deadfire::Transformers
  class Nesting < Transformer
    NEST_SELECTOR = "&"
    START_BLOCK_CHAR = "{"
    END_BLOCK_CHAR = "}"
    OPENING_SELECTOR_PATTERN  = /\..*\{/
    OPENING_SELECTOR_PATTERN2 = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/

    def name
      "Nesting"
    end
    
    def matches?(line)
      line.strip.start_with?("&")
    end
    
    def transform(line, buffer, output)
      line = buffer.gets unless line
      output << "}\n"
      block_name = []
      found_end_for_current_nested_block = false
      lineno = output.size
      block_name << find_block_name(output, lineno)

      while ! buffer.eof?
        if line.strip.start_with?(NEST_SELECTOR)
          spaces = calculate_spaces_to_add(line)
          output << "#{spaces}#{rewrite_line(line.strip, block_name.join(" "))}\n"
        else
          output << line
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

    private

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