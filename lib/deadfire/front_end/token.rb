# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class Token
      attr_reader :type, :lexeme, :literal, :lineno

      def initialize(type, lexeme, literal, lineno)
        @type = type
        @lexeme = lexeme
        @literal = literal
        @lineno = lineno
      end

      def to_s
        "[#{type}] #{lexeme} #{literal}"
      end
    end
  end
end
