require 'strscan'

module Deadfire
  class Apply
    TAG = "@apply"
    NEWLINE = "\n"

    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = [] }

    def initialize(input, lineno)
      @buffer = input
      @output = []
      @lineno = lineno
    end

    def resolve
      raise EarlyApplyException.new(@buffer, @lineno) if Apply.cached_mixins.empty?

      @buffer.split(" ").each do |css|
        next if css.include?(TAG)
        css.gsub!(";", "")

        @output << find(css)
      end

      @output.join(NEWLINE)
    end

    private

      # find css class key/val from hash, otherwise throw because the mixin is not defined
      def find(key)
        raise EarlyApplyException.new(key, @lineno) unless Apply.cached_mixins.include?(key)

        Apply.cached_mixins[key]
      end
  end
end