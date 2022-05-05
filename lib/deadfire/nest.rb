# frozen_string_literal: true

module Deadfire
  class Nest
    NEST_SELECTOR = "&"
    START_BLOCK_CHAR = "{"
    END_BLOCK_CHAR = "{"
    NEST_INSIDE_LINE = /\s*#{NEST_SELECTOR}\s*\{/

    class << self
      def match?(current_line)
        current_line.strip.start_with?(NEST_SELECTOR) || current_line =~ NEST_INSIDE_LINE
      end

      def resolve(buffer, output, current_line = nil, lineno = 0)
        current_line = buffer.gets unless current_line
        nested_content = []

        while ! buffer.eof?
          nested_content << current_line
          lineno += 1
          if current_line.strip.end_with?(END_BLOCK_CHAR)
            break
          else
            current_line = buffer.gets
          end
        end

        output << current_line if buffer.eof?

        # read the parent content until we find the end of the parent block
        while ! buffer.eof?
          output << current_line
          lineno += 1
          if current_line.strip.end_with?(END_BLOCK_CHAR)
            break
          else
            current_line = buffer.gets
          end
        end

        block_name = find_block_name(output)
        output << rewrite_line(nested_content, block_name).join

        nil
      end

      def extract_selector(line)
        line.tr(START_BLOCK_CHAR, "").strip
      end

      def rewrite_line(nested_content, selector)
        current_line = nested_content.shift
        content = if multiple_selectors?(current_line)
          current_line.strip.each_char.map do |s|
            if s == NEST_SELECTOR
              selector
            else
              s
            end
          end
        else
          rewrite_selector(current_line, selector)
        end

        nested_content.insert(0, content)
      end

      def rewrite_selector(line, selector)
        selector + line.strip.slice(1..-1)
      end

      def multiple_selectors?(line)
        line.split.count { |s| s.start_with?(NEST_SELECTOR) } > 1
      end

      def find_block_name(output, lineno = nil)
        lineno = output.size unless lineno
        current_line = output[lineno]

        if current_line =~ Deadfire::Parser::OPENING_SELECTOR_PATTERN2
          extract_selector(current_line)
        else
          find_block_name(output, lineno - 1)
        end
      end
    end
  end
end