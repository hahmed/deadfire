# frozen_string_literal: true

require_relative "deadfire/css_buffer"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/parser"
require_relative "deadfire/transformers/transformer"
require_relative "deadfire/transformers/apply"
require_relative "deadfire/transformers/comment"
require_relative "deadfire/transformers/import"
require_relative "deadfire/transformers/mixin"
require_relative "deadfire/transformers/nesting"
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
