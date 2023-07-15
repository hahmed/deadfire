# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class NestingNode < BaseNode
      attr_reader :property, :value

      def initialize(property, value)
        @property = property
        @value = value
      end

      def accept(visitor)
        visitor.visit_nesting_node(self)
      end
    end
  end
end