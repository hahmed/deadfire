# frozen_string_literal: true

module Deadfire::Transformers
  class Comment < Transformer
    BEGIN_COMMENT_PATTERN     = "/*"
    END_COMMENT_PATTERN       = "*/"

    def name
      "Comment"
    end
    
    def matches?(line)
      line.strip.start_with?(BEGIN_COMMENT_PATTERN)
    end

    def keep_comments?
      true
    end
    
    def transform(line, buffer, output)
      output << line if keep_comments?

      unless line.include?(END_COMMENT_PATTERN)
        while ! line.include?(END_COMMENT_PATTERN) && ! buffer.eof?
          line = buffer.gets
          output << line if keep_comments?
        end
      end
    end
  end
end