# frozen_string_literal: true

require_relative "deadfire/css_buffer"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/parser"
require_relative "deadfire/filename_helper"
require_relative "deadfire/transformers/transformer"
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

    def parse(content, options = {})
      Parser.parse(content, options)
    end
  end
end
