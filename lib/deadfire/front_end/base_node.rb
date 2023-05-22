module Deadfire
  module FrontEnd
    class BaseNode
      attr_reader :left, :right, :operator

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end
    end
  end
end
