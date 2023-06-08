# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class StatementNode
      attr_reader :statements

      def initialize
        @statements = []
      end

      def add_statement(statement)
        @statements << statement
      end
    end
  end
end
