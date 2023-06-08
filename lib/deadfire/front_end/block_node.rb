# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class BlockNode < BaseNode
      attr_reader :declarations

      def initialize
        @declarations = []
      end

      def <<(node)
        @declarations << node
      end

      def accept(visitor)
        visitor.visit_block_node(self)
      end
    end
  end
end
