require 'stringio'

module Deadfire
  class Parser
    NEWLINE = "\n"
    OPENING_SELECTOR_PATTERN  = /\..*\{/
    OPENING_SELECTOR_PATTERN2 = /\s*\{/
    CLOSING_SELECTOR_PATTERN  = /\s*\}/
    ROOT_SELECTOR_PATTERN     = /\::root*\}/
    IMPORT_SELECTOR_PATTERN   = "@import"
    APPLY_SELECTOR_PATTERN    = "@apply"

    def self.call(options)
      new(options).call
    end

    attr_reader :output

    def initialize(options)
      @buffer   = StringIO.new(options[:input])
      @filename = options[:filename]
      @output   = StringIO.new
      @lineno   = 0
      @imports  = []
      @mixins   = []
    end

    def call
      while ! buffer.eof?
        output.write(process_line(buffer.gets))
      end

      output.string
    end

    private
      attr_reader :buffer, :lineno, :imports, :apply, :dirname, :filename

      def process_line(line)
        if line.include?(IMPORT_SELECTOR_PATTERN)
          import = Import.new(line, buffer.lineno)
          imports << import
          import.resolve
        elsif line.include?(APPLY_SELECTOR_PATTERN)
          apply = Apply.new(line, buffer.lineno)
          apply.resolve
        else
          line
        end
      end
  end
end
