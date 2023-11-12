# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class SelectorNode < BaseNode
      attr_reader :selector, :mixin_name

      def initialize(tokens)
        @selector = tokens_to_selector(tokens)
        @mixin_name = fetch_mixin_name_from(tokens)
      end

      def accept(visitor)
        visitor.visit_selector_node(self)
      end

      def cacheable?
        selector.start_with?(".")
      end

      private

      # TODO:
      # For descendant values such as `a b`, we need to add a space between the tokens,
      # otherwise all other values will be concatenated together.
      def tokens_to_selector(tokens)
        tokens.map(&:lexeme).join("").strip
      end

      # https://sass-lang.com/guide
      # https://sass-lang.com/documentation/style-rules/selector
      # TODO: this needs some tests and a lot more work
      # not all selectors are valid mixin names
      def fetch_mixin_name_from(tokens)
        @_cached_mixin_name ||= begin
          name = []
          tokens.each do |token|
            case token.type
            when :right_paren, :left_paren
              break
            when :colon
              name << token.lexeme
            else
              name << token.lexeme
            end
          end
          name.join("")
        end
      end
    end
  end
end
