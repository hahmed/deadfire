# frozen_string_literal: true

module Deadfire
  class ErrorReporter # :nodoc:
    attr_reader :errors

    def initialize
      @errors = []
    end

    def error(line, message)
      error = Error.new(line, message)
      Deadfire.configuration.logger.error(error.to_s) unless Deadfire.configuration.supressed
      @errors << error
    end

    def errors?
      @errors.any?
    end

    private

    # create error struct with line and message
    Error = Struct.new(:line, :message) do
      def to_s
        "Line #{line}: #{message}"
      end
    end
  end
end
