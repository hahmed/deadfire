# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class StylesheetNode
      attr_reader :statements

      def initialize
        @statements = []
      end

      def add_child_node(node)
        @statements << node
        node.parent = self
      end

      def to_css
        @statements.map(&:to_css).join
      end
    end
  end
end
