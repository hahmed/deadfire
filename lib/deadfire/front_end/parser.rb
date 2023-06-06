module Deadfire
  module FrontEnd
    class Parser
      attr_reader :error_reporter, :tokens, :options, :current

      def initialize(tokens, error_reporter, options = {})
        @error_reporter = error_reporter
        @tokens = []
        @options = {}
        @current = 0
        @statements = []
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
            at_rule_declaration
          elsif matches_ruleset?
            ruleset_declaration
          else
            throw "error eval-ing statement"
          end
        end

        statements
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
        match?(:at_keyword)
      end

      def matches_ruleset?
        match?(:ruleset)
      end

      def at_rule_declaration
        # This will break for at_rule, because some types are a bit more complex, or do I need to simplify all into at_keyword only?
        # have a think about this, because I may need to peek and check for specific types and consume acordingly, because
        # not all at_keywords have blocks for example.
        consume(:at_keyword, "Expect at keyword")
        consume(:left_brace, "Expect left brace")

        block = block

        consume(:right_brace, "Expect right brace")

        AtRuleNode.new(block)
      end

      def ruleset_declaration
        consume(:ruleset, "Expect ruleset")

        selectors = selectors

        consume(:left_brace, "Expect left brace")

        declarations = declarations

        consume(:right_brace, "Expect right brace")

        RulesetNode.new(selectors, declarations)
      end
  end
end
