module Deadfire
  class Processor
    NEWLINE = "\n"
    OPENING_SELECTOR_PATTERN = /\..*\{/
    OPENING_SELECTOR_PATTERN2 = /\s*\{/
    CLOSING_SELECTOR_PATTERN = /\s*\}/

    def self.run(input)
      new(input).run
    end

    attr_reader :output, :input

    def initialize(input)
      @input   = input
      @output  = ""
    end

    def run
      # 1. add every import to files
      # 2. update every @apply directives

      # scan for every @apply, find the index, then replace that @apply with the correct stuff

      input.split(NEWLINE).each do |line|
      end

      output
    end
  end
end
