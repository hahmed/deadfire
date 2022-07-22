# frozen_string_literal: true

module Deadfire::Transformers
  class Transformer
    def name
      self.class.name
    end
  
    def matches?(line)
      false
    end
  
    def transform(line, buffer, lineno, output); end
  
    def reset; end
  end
end
