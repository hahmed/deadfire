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
        nested_level = 0
        end_nested_block_found = false

        while ! buffer.eof?
          # if that is the prev line
          # we should be reading the buffer instead? or memoizing the block name...
          # check if the block_name is the same as the prev block...
          # NOTE: update to regex or something 
          # if START+END found on line then do ???
          # &.c { text-transform:uppercase }
          # should be easy to find parent block and rewrite current line and close block

          # If only found start nest block &
          # - then read everything until we find the end of the block
          
          # if end found do xx
          # if neither found do xx
          # track nested level
          if current_line.strip.start_with?(NEST_SELECTOR)
            spaces = calculate_spaces_to_add(current_line)
            nested_level += 1

            end_nested_block_found = false


            # the output will pick the name from the css/parsed output e.g. table.colortable th instead of table.colortable
            # do we only need the root selector? how far are we nested?
            # this saves us computing selector if we memoize it
            block_name << find_block_name(output, lineno)
            output <<  "#{spaces}#{rewrite_line(current_line.strip, block_name.join(" "))}\n"
          else
            output << current_line
          end

          lineno += 1
          break if current_line.strip.end_with?(END_BLOCK_CHAR)
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

      # what's in the current line? before the rewrite?
      # & th { -- what does this mean to the parser? nothing without context
      # another way to look at this is, we don't need to write any of the blocks?
      # that way we can find the parents block name quicker?
      
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