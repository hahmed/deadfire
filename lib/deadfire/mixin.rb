module Deadfire
  class Mixin
    def initialize(buffer, current_line = nil, lineno = 0)
      @buffer = buffer
      @current_line = current_line
      @output = ""
    end

    def resolve
      end_tag = false
      output_line = true
      @current_line = @buffer.gets unless @current_line

      # skip if first line is root tag
      if @current_line.include? Deadfire::Parser::ROOT_SELECTOR_PATTERN
        @output << @current_line
        @current_line = @buffer.gets
      end

      while !end_tag
        # if current_line has { in it, then it's a mixin
        if @current_line =~ Deadfire::Parser::OPENING_SELECTOR_PATTERN2
          output_line = false
          name = extract_mixin_name(@current_line)
          properties = extract_properties_from_mixin(@buffer, @current_line)
          Deadfire::Apply.cached_mixins[name] = properties
        elsif @current_line =~ Deadfire::Parser::CLOSING_SELECTOR_PATTERN
          # when it's not a mixin, check if end tag exists on line
          end_tag = true
        end

        @output << @current_line if output_line

        if end_tag || @buffer.eof?
          return @output
        end

        @current_line = @buffer.gets
        output_line = true
      end
    end

    def extract_mixin_name(current_line)
      # replace . with whitespace and { with whitespace
      current_line.tr("{", "").tr(".", "").tr(":", "").strip
    end

    def extract_properties_from_mixin(buffer, current_line)
      properties = {}
      current_line = buffer.gets # skip opening {
      while current_line !~ Deadfire::Parser::CLOSING_SELECTOR_PATTERN
        name, value = extract_name_and_values(current_line)
        properties[name] = value
        current_line = buffer.gets
      end
      properties
    end

    def extract_name_and_values(current_line)
      # replace . with whitespace and { with whitespace
      name, value = current_line.split(":")
      value = value.gsub(";", "")
      [name, value].map(&:strip)
    end
  end
end