module Deadfire
  module FrontEnd
    class BaseNode
      attr_reader :left, :right, :operator

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end

      def accept
        raise NotImplementedError
      end
    end
  end
end
