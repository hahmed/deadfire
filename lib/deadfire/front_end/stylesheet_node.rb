# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class StylesheetNode
      attr_reader :statements

      def initialize
        @statements = []
      end

      def accept(visitor)
        visitor.visit_stylesheet_node(self)
      end

      def <<(node)
        @statements << node
      end
    end
  end
end
