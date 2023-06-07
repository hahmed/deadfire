module Deadfire
  module FrontEnd
    class AtRuleNode < BaseNode
      attr_reader :at_keyword, :value, :block

      def initialize(at_keyword, value, block)
        @at_keyword = at_keyword
        @value = value
        @block = block
      end

      def accept(visitor)
        visitor.visit_at_rule_node(self)
      end
    end
  end
end
