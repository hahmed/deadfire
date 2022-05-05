# frozen_string_literal: true

require_relative "deadfire/apply"
require_relative "deadfire/comment"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/import"
require_relative "deadfire/mixin"
require_relative "deadfire/nest"
require_relative "deadfire/parser"
require_relative "deadfire/version"

module Deadfire
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(@configuration)
    end

    def parse(content)
      Parser.call(content)
    end
  end
end
