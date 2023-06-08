# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class CombinatorNode < BaseNode
      attr_reader :operator

      def initialize(operator)
        @operator = operator
      end

      def accept(visitor)
        visitor.visit_combinator_node(self)
      end
    end
  end
end
