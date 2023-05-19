module Deadfire
  class Parser2
    attr_reader :error_reporter

    def initialize
      @error_reporter = ErrorReporter.new
    end

    def parse(content, options = {})
      scanner = FrontEnd::Scanner.new(content, @error_reporter)
      tokens = scanner.scan_tokens

      tokens.each do |token|
        puts token
      end
    end

    def errors?
      @error_reporter.errors?
    end
  end
end
