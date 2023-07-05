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
        # it looks like the visitor pattern is used by the interpreter, but does the
        # interpreter do the grouping of tokens into statements?
        # the parser does the grouping of tokens into statements so what's the value of the epxressions?
        # do we use that to unfold nested css? or deal with imports?
        # this is where I need to "parse" or group the words into statements/rules + at_rules, then within that, I need to further
        # parse words into expressions? if that's the right term.


        # top level it's a list of statements
        # statements are either rules or at-rules
        # rules are selectors + declarations
        # at-rules are at-keyword + block
        # block is a list of declarations?
        # declarations are property + value

        # //< Statements and State declaration
        # //> Classes parse-class-declaration
        #   private Stmt classDeclaration() {
        #     Token name = consume(IDENTIFIER, "Expect class name.");
        # //> Inheritance parse-superclass

        #     Expr.Variable superclass = null;
        #     if (match(LESS)) {
        #       consume(IDENTIFIER, "Expect superclass name.");
        #       superclass = new Expr.Variable(previous());
        #     }

        # //< Inheritance parse-superclass
        #     consume(LEFT_BRACE, "Expect '{' before class body.");

        #     List<Stmt.Function> methods = new ArrayList<>();
        #     while (!check(RIGHT_BRACE) && !isAtEnd()) {
        #       methods.add(function("method"));
        #     }

        #     consume(RIGHT_BRACE, "Expect '}' after class body.");

        # /* Classes parse-class-declaration < Inheritance construct-class-ast
        #     return new Stmt.Class(name, methods);
        # */
        # //> Inheritance construct-class-ast
        #     return new Stmt.Class(name, superclass, methods);
        # //< Inheritance construct-class-ast
        #   }

        while !is_at_end?
          if matches_at_rule?
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

        error_reporter.error(peek, message)
      end

      def matches_at_rule?
        match?(:at_rule)
      end

      def at_rule_declaration
        consume(:at_rule, "Expect at rule")
        keyword = previous

        # peek until we get to ; or {, if we reach ; then add to at rule node and return
        values = []
        while !match?(:semicolon, :left_brace)
          values << advance
        end

        if previous.type == :semicolon
          if keyword.lexeme == "@apply"
            return ApplyNode.new(values)
          else
            values << previous # add the semicolon to the values
            return AtRuleNode.new(keyword, values, nil)
          end
        end

        AtRuleNode.new(keyword, values[0..-1], parse_block) # remove the left brace, because it's not a value, but part of the block
      end

      def parse_block
        block = BlockNode.new
        block << previous

        while !is_at_end?
          puts "peek: #{peek.inspect}"
          if match?(:right_brace)
            break
          elsif matches_at_rule?
            block << at_rule_declaration
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
    end
  end
end
