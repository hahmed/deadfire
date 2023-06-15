# frozen_string_literal: true

require_relative "deadfire/ast_printer"
require_relative "deadfire/css_buffer"
require_relative "deadfire/css_generator"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/error_reporter"
require_relative "deadfire/parser"
require_relative "deadfire/parser_engine"
require_relative "deadfire/spec"
require_relative "deadfire/filename_helper"
require_relative "deadfire/version"
require_relative "deadfire/front_end/scanner"
require_relative "deadfire/front_end/token"
require_relative "deadfire/front_end/parser"
require_relative "deadfire/front_end/base_node"
require_relative "deadfire/front_end/at_rule_node"
require_relative "deadfire/front_end/block_node"
require_relative "deadfire/front_end/declaration_node"
require_relative "deadfire/front_end/selector_node"
require_relative "deadfire/front_end/property_node"
require_relative "deadfire/front_end/ruleset_node"
require_relative "deadfire/front_end/stylesheet_node"
require_relative "deadfire/front_end/value_node"

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
