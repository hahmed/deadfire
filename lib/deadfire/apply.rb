module Deadfire
  class Apply
    TAG = "@apply"
    NEWLINE = "\n"

    def initialize(input)
      @cached_css = {}
      @input = input
    end

    def self.rework(input)
      new(input).rework
    end

    def rework
      output = []
      input.split(NEWLINE).each do |line|
        case
        when line.include?(TAG)
          _, values = line.split(" ")
          css_keys = find_apply_keys(line)
          css_keys.each do |key|
            puts key.inspect
            output << "  " + find(key)
          end
        else
          output << line
        end
      end
      separated_without_empty_lines(output)
    end

    private

      attr_reader :cached_css, :input

      def find(key)
        if cached_css.include?(key)
          cached_css[key]
        else
          cached_css[key] = find_css(key)
        end
      end

      def find_css(key)
        # find class from input, then pull out css and add to cache
        "padding: 0.5rem;"
      end

      def find_apply_keys(line)
        values = line.gsub("@apply", "")
        values.gsub!(";", "").strip!
        values.split(" ").map { |key| ".#{key}" }
      end

      def separated_without_empty_lines(output)
        output.reject { |line| line.strip.empty? }.join(NEWLINE)
      end
  end
end