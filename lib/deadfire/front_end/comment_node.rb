# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class CommentNode < BaseNode
      attr_reader :comment

      def initialize(comment)
        @comment = comment
      end

      def accept(visitor)
        visitor.visit_comment_node(self)
      end
    end
  end
end
