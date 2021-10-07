# frozen_string_literal: true

module Deadfire
  class Mixin
    class << self
      def resolve(buffer, current_line = nil, lineno = 0)
        end_tag = false
        output_line = true
        output = StringIO.new
        current_line = buffer.gets unless current_line

        # skip if first line is root tag
        if current_line.include? Deadfire::Parser::ROOT_SELECTOR_PATTERN
          output.write current_line
          current_line = buffer.gets
        end

        while !end_tag
          if current_line =~ Deadfire::Parser::OPENING_SELECTOR_PATTERN2
            output_line = false
            name = extract_mixin_name(current_line)
            properties = extract_properties_from_mixin(buffer, current_line)
            Deadfire::Apply.cached_mixins[name] = properties
          elsif current_line =~ Deadfire::Parser::CLOSING_SELECTOR_PATTERN
            end_tag = true
          end

          output.write current_line if output_line

          if end_tag || buffer.eof?
            return output.string
          end

          current_line = buffer.gets
          output_line = true
        end
      end

      def extract_mixin_name(current_line)
        current_line.tr("{", "").tr(".", "").tr(":", "").strip
      end

      # TODO: handle css properties that have hanging comments e.g. color: red;  /* Set text color to red */
      def extract_properties_from_mixin(buffer, current_line)
        properties = {}
        current_line = buffer.gets # skip opening {
        while current_line !~ Deadfire::Parser::CLOSING_SELECTOR_PATTERN && !buffer.eof?
          name, value = extract_name_and_values(current_line)
          properties[name] = value
          current_line = buffer.gets
        end
        properties
      end

      def extract_name_and_values(current_line)
        name, value = current_line.split(":")
        value = value.gsub(";", "")
        [name, value].map(&:strip)
      end
    end
  end
end