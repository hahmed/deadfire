# frozen_string_literal: true

module Deadfire
  class Apply
    TAG = "@apply"
    NEWLINE = "\n"

    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = {} }

    class << self
      # p {
      #   @apply --font-bold --text-red;
      # }
      # => p {
      # =>   font-weight: bold;
      # =>   color: red;
      # => }
      def resolve(input, lineno)
        buffer = input.dup
        output = []
        lineno = lineno.to_i
        space  = " "
        space_counter = 0
        import_start_tag = "@"

        raise EarlyApplyException.new(buffer, lineno) if Apply.cached_mixins.empty?

        buffer.each_char do |char|
          break if char == import_start_tag
          space_counter += 1
        end

        buffer.split(" ").each do |css|
          next if css.include?(TAG)
          css.gsub!(";", "")
          
          find(css, lineno).each_pair do |key, value|
            output << "#{space * space_counter}#{key}: #{value};"
          end
        end

        output.join(NEWLINE)
      end

      private

        # find css class key/val from hash, otherwise throw because the mixin is not defined
        def find(key, lineno)
          raise EarlyApplyException.new(key, lineno) unless Apply.cached_mixins.include?(key)

          Apply.cached_mixins[key]
        end
    end
  end
end