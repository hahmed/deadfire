module Deadfire
  module FrontEnd
    class AtRuleNode < BaseNode
      def accept(visitor)
        visitor.visit_at_rule_node(self)
      end
    end
  end
end
