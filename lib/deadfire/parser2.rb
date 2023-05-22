module Deadfire
  class Parser2
    attr_reader :error_reporter, :tokens, :options, :current

    def initialize(content, options = {})
      @error_reporter = ErrorReporter.new
      @tokens = []
      @options = {}
      @current = 0
      @scanner = FrontEnd::Scanner.new(content, @error_reporter)
    end

    def parse
      tokens = @scanner.scan_tokens

      tokens.each do |token|
        puts token
      end
    end

    def errors?
      @error_reporter.errors?
    end
  end
end
