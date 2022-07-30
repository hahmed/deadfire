# frozen_string_literal: true

module Deadfire::Transformers
  class Apply < Transformer
    SELECTOR = "@apply"
    NEWLINE = "\n"

    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = {} }

    def name
      "Apply"
    end
    
    def matches?(line)
      line.include?(SELECTOR)
    end
    
      # p {
      #   @apply --font-bold --text-red;
      # }
      # => p {
      # =>   font-weight: bold;
      # =>   color: red;
      # => }
    def transform(line, buffer, output)
      current_line = line.dup
      output = []
      space  = " "
      space_counter = 0
      import_start_tag = "@"

      raise Deadfire::EarlyApplyException.new(buffer, buffer.lineno) if Apply.cached_mixins.empty?

      current_line.each_char do |char|
        break if char == import_start_tag
        space_counter += 1
      end

      current_line.split(" ").each do |css|
        next if css.include?(SELECTOR)
        css.gsub!(";", "")
        
        find(css, buffer.lineno).each_pair do |key, value|
          output << "#{space * space_counter}#{key}: #{value};"
        end
      end

      output.join(NEWLINE)
    end

    private

    # find css class key/val from hash, otherwise throw because the mixin is not defined
    def find(key, lineno)
      raise Deadfire::EarlyApplyException.new(key, lineno) unless Apply.cached_mixins.include?(key)

      Apply.cached_mixins[key]
    end
  end
end