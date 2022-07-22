# frozen_string_literal: true

module Deadfire
  class Parser
    def self.call(options)
      new(options).call
    end

    attr_reader :output

    def initialize(content, options = {})
      @content  = content
      @filename = options[:filename]
      @output   = []
      @lineno   = 0
      @imports  = []
    end

    def buffer
      @buffer ||= CssBuffer.new(@content)
    end

    def transformers
      @transformers ||= [
        Transformers::Comment.new,
        Transformers::Import.new,
        Transformers::Mixin.new,
        Transformers::Apply.new,
        Transformers::Nesting.new,
      ]
    end

    def call
      while ! buffer.eof?
        a =  process_line(buffer.readline)
        @output << a

        @lineno += 1
      end

      # todo, somewhere there is a an array output that is not beig handled or 
      # ownershiped
      @output.join
    end

    private

      def process_line(line)
        transformers.each do |transformer|
          return transformer.transform(line, buffer, @lineno, @output) if transformer.matches?(line)
        end

        line
      end
  end
end
