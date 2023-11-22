# frozen_string_literal: true

require_relative "deadfire/ast_printer"
require_relative "deadfire/css_buffer"
require_relative "deadfire/css_generator"
require_relative "deadfire/configuration"
require_relative "deadfire/errors"
require_relative "deadfire/error_reporter"
require_relative "deadfire/interpreter"
require_relative "deadfire/parser_engine"
require_relative "deadfire/spec"
require_relative "deadfire/filename_helper"
require_relative "deadfire/version"
require_relative "deadfire/front_end/scanner"
require_relative "deadfire/front_end/token"
require_relative "deadfire/front_end/parser"
require_relative "deadfire/front_end/base_node"
require_relative "deadfire/front_end/apply_node"
require_relative "deadfire/front_end/at_rule_node"
require_relative "deadfire/front_end/block_node"
require_relative "deadfire/front_end/comment_node"
require_relative "deadfire/front_end/newline_node"
require_relative "deadfire/front_end/ruleset_node"
require_relative "deadfire/front_end/selector_node"
require_relative "deadfire/front_end/stylesheet_node"

module Deadfire
  CSS_FILE_EXTENSION = ".css"

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
      configure do |config|
        config.root_path = options[:root_path]
        config.keep_comments = options[:keep_comments]
        config.keep_whitespace = options[:keep_whitespace]
      end

      parser = ParserEngine.new(content)
      # TODO: hook into a logger and report the errors
      parser.parse
    end
  end
end
