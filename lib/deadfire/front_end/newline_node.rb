# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class NewlineNode < BaseNode
      attr_reader :text

      def initialize(text)
        @text = text
      end

      def accept(visitor)
        visitor.visit_newline_node(self)
      end
    end
  end
end
