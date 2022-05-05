# frozen_string_literal: true

module Deadfire
  class Comment
    BEGIN_COMMENT_PATTERN  = "/*"
    END_COMMENT_PATTERN    = "*/"

    class << self
      def match?(current_line)
        current_line.start_with?(BEGIN_COMMENT_PATTERN)
      end

      def write(buffer, line, output)
        output << line

        unless line.include?(END_COMMENT_PATTERN)
          while ! line.include?(END_COMMENT_PATTERN) && ! buffer.eof?
            line = buffer.gets
            output << line
          end
        end
      end
    end
  end
end