module Deadfire
  class ErrorReporter
    attr_reader :errors

    def initialize
      @errors = []
    end

    def error(line, message)
      @errors << Error.new(line, message)
    end

    def errors?
      @errors.any?
    end

    private

    # create error struct with line and message
    Error = Struct.new(:line, :message)
  end
end
