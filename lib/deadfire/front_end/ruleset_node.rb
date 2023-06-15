# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class RulesetNode < BaseNode
      attr_reader :selector, :block

      def initialize(selector, block)
        @selector = selector
        @block = block
      end

      def accept(visitor)
        visitor.visit_ruleset_node(self)
      end
    end
  end
end
