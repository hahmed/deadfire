# frozen_string_literal: true
require "debug"

module Deadfire
  class Nest
    NEST_SELECTOR = "&"
    START_BLOCK_CHAR = "{"
    END_BLOCK_CHAR = "}"
    NEST_INSIDE_LINE = /\s*#{NEST_SELECTOR}\s*\{/

    class << self
      def match?(current_line)
        current_line.strip.start_with?(NEST_SELECTOR) || current_line =~ NEST_INSIDE_LINE
      end

      def resolve(buffer, output, current_line = nil, lineno = 0)
        current_line = buffer.gets unless current_line
        output << "}\n"
        lineno += 1
        block_name = []
        found_end_for_current_nested_block = false
        block_name << find_block_name(output, lineno)

        while ! buffer.eof?
          if current_line.strip.start_with?(NEST_SELECTOR)
            spaces = calculate_spaces_to_add(current_line)
            output << "#{spaces}#{rewrite_line(current_line.strip, block_name.join(" "))}\n"
          else
            output << current_line
          end

          lineno += 1
          if current_line.strip.end_with?(END_BLOCK_CHAR)
            break
          end
          current_line = buffer.gets
        end

        # if there is an ending block after the nested content, that can be ignored
        current_line = buffer.gets
        unless current_line.strip.end_with?(END_BLOCK_CHAR)
          buffer.ungetc(current_line)
        end

        nil
      end
  
      def calculate_spaces_to_add(current_line)
        unless current_line =~ Deadfire::Parser::OPENING_SELECTOR_PATTERN2 || current_line =~ Deadfire::Parser::CLOSING_SELECTOR_PATTERN
          "  "
        else
          ""
        end
      end

      def extract_selector(line)
        line.tr(START_BLOCK_CHAR, "").strip
      end

      def rewrite_line(current_line, selector)
        case number_of_selectors_in(current_line)
        when 0
          current_line
        when 1
          "#{selector} { #{extract_selector(current_line)} }"
        else
          current_line.strip.each_char.map do |s|
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
        current_line = output[lineno]

        if current_line.to_s =~ Deadfire::Parser::OPENING_SELECTOR_PATTERN2
          extract_selector(current_line)
        else
          find_block_name(output, lineno - 1)
        end
      end
    end
  end
end