# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class SelectorNode < BaseNode
      attr_reader :selector

      def initialize(tokens)
        @selector = tokens_to_selector(tokens)
      end

      def accept(visitor)
        visitor.visit_selector_node(self)
      end

      private

      # TODO:
      # For descendant values such as `a b`, we need to add a space between the tokens,
      # otherwise all other values will be concatenated together.
      def tokens_to_selector(tokens)
        tokens.map(&:lexeme).join("")
      end
    end
  end
end
