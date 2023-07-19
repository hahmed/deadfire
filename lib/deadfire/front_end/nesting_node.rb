# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class NestingNode < BaseNode
      attr_reader :property, :value, :block

      def initialize(property, value, block = nil)
        @property = property
        @value = value
        @block = block
      end

      def update_nesting(updated_selector)
        @property = Token.new(:value, updated_selector, nil, @property.lineno)
      end

      def lexeme
        value.map(&:lexeme).join("")
      end

      def accept(visitor)
        visitor.visit_nesting_node(self)
      end
    end
  end
end
