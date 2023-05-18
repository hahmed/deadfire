# frozen_string_literal: true

require_relative "deadfire/css_buffer"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/error_reporter"
require_relative "deadfire/parser"
require_relative "deadfire/parser2"
require_relative "deadfire/spec"
require_relative "deadfire/filename_helper"
require_relative "deadfire/version"

module Deadfire
  class << self
    attr_reader :config

    def configuration
      @config ||= Configuration.new
    end

    def reset
      @config = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def parse(content, options = {})
      Parser.parse(content, options)
    end
  end
end
