# frozen_string_literal: true

module Deadfire
  class ParserEngine # :nodoc:
    attr_reader :error_reporter, :options, :current

    def initialize(content, options = {})
      @error_reporter = ErrorReporter.new
      @options = {}
      @scanner = FrontEnd::Scanner.new(content, error_reporter)
    end

    def parse
      ast = _parse
      interpreter = Interpreter.new
      ast.statements.each do |node|
        interpreter.interpret(node)
      end
      CssGenerator.new(ast).generate
    end

    def print_ast
      ast = _parse
      printer = AstPrinter.new
      ast.statements.each do |node|
        printer.print(node)
      end
    end

    def errors?
      @error_reporter.errors?
    end

    private

    def _parse
      tokens = @scanner.tokenize
      # tokens.each do |token|
      #   puts token.inspect
      # end
      FrontEnd::Parser.new(tokens, error_reporter).parse
    end
  end
end
