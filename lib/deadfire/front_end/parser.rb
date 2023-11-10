# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class Parser
      attr_reader :error_reporter, :tokens, :options, :current

      def initialize(tokens, error_reporter)
        @error_reporter = error_reporter
        @tokens = tokens
        @current = 0
        @stylesheet = StylesheetNode.new
      end

      def parse
        # top level it's a list of statements
        # statements are either rules or at-rules
        # rules are selectors + declarations
        # at-rules are at-keyword + block
        # block is a list of declarations?
        # declarations are property + value
        while !is_at_end?
          if check(:comment)
            @stylesheet << add_comment if Deadfire.configuration.keep_comments
          elsif matches_at_rule?
            @stylesheet << at_rule_declaration
          else
            @stylesheet << ruleset_declaration
          end
        end
        @stylesheet
      end

      private

      def is_at_end?
        peek.type == :eof
      end

      def peek
        tokens[current]
      end

      def previous
        tokens[current - 1]
      end

      def advance
        @current += 1 unless is_at_end?
        previous
      end

      def check(type)
        return false if is_at_end?

        peek.type == type
      end

      def match?(*types)
        types.each do |type|
          if check(type)
            advance
            return true
          end
        end

        false
      end

      def consume(type, message)
        if check(type)
          advance
          return
        end

        error_reporter.error(peek.lineno, message)
      end

      def matches_at_rule?
        check(:at_rule)
      end

      def matches_nested_rule?
        match?(:ampersand)
      end

      def parse_block
        block = BlockNode.new
        block << previous

        while !is_at_end?
          if match?(:right_brace)
            break
          elsif matches_at_rule?
            block << at_rule_declaration
          elsif match?(:left_brace)
            block << parse_block
          else
            block << advance
          end
        end

        block << previous
        block
      end

      def ruleset_declaration
        values = []
        while !match?(:left_brace)
          values << advance
        end

        selector = SelectorNode.new(values[0..-1])

        block = parse_block
        RulesetNode.new(selector, block)
      end

      def add_comment
        consume(:comment, "Expect comment")
        CommentNode.new(previous)
      end

      def at_rule_declaration
        consume(:at_rule, "Expect at rule")
        keyword = previous

        # peek until we get to ; or {, if we reach ; then add to at rule node and return
        values = []
        while !match?(:semicolon, :left_brace) && !is_at_end?
          values << advance
        end

        if previous.type == :semicolon
          if keyword.lexeme == "@apply"
            return ApplyNode.new(keyword, values)
          else
            values << previous # add the semicolon to the values
            return AtRuleNode.new(keyword, values, nil)
          end
        end

        AtRuleNode.new(keyword, values[0..-1], parse_block) # remove the left brace, because it's not a value, but part of the block
      end
    end
  end
end
