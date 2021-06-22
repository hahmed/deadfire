require_relative "deadfire/version"
require_relative "deadfire/configuration"
require_relative "deadfire/parser"
require_relative "deadfire/apply"
require_relative "deadfire/import"
require_relative "deadfire/mixin"

module Deadfire
  class Error < StandardError; end
  class DirectoryNotFoundError < StandardError; end
  class FileNotFoundError < StandardError; end
  class EarlyApplyException < StandardError
    def initialize(input = "", lineno = "")
      msg = if input
        "Error with input: `#{input}` line: #{lineno}"
      else
        "Apply called too early in css. There are no mixins defined."
      end

      super(msg)
    end
  end

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def execute(file)
      Parser.call(file)
    end
  end
end
