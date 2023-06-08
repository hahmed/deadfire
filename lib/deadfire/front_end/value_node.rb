# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class Value < BaseNode
      attr_reader :tokens

      def initialize(tokens)
        @tokens = tokens
      end

      def to_s
        @tokens.join(' ')
      end
    end
  end
end
