# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class BaseNode
      def accept
        raise NotImplementedError
      end
    end
  end
end
