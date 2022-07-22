# frozen_string_literal: true

module Deadfire::Transformers
  class Mixin < Transformer
    ROOT_SELECTOR = ":root {"
    OPENING_SELECTOR_PATTERN2 = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/

    def name
      "Import"
    end
    
    def matches?(line)
      line.strip.start_with?(ROOT_SELECTOR)
    end

    def transform(line, buffer, lineno, output)
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
        if line =~ OPENING_SELECTOR_PATTERN2
          output_line = false
          name = extract_mixin_name(line)
          properties = extract_properties_from_mixin(buffer, line)
          Deadfire::Transformers::Apply.cached_mixins[name] = properties
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

      content.join
    end

    private

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
  end
end