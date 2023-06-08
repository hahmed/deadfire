# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class RulesetNode < BaseNode
      def accept(visitor)
        visitor.visit_ruleset_node(self)
      end

      def to_s
        "#{operator.lexeme} #{right}"
      end
    end
  end
end
