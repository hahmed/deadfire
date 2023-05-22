module Deadfire
  module FrontEnd
    class SelectorNode < BaseNode
      def accept(visitor)
        visitor.visit_selector_node(self)
      end
    end
  end
end
