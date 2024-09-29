# frozen_string_literal: true

module Deadfire
  class ParserEngine # :nodoc:
    attr_reader :error_reporter, :options, :current

    def initialize(content, options = {})
      @error_reporter = ErrorReporter.new
      @options = {}
      @asset_loader = AssetLoader.new(options[:filename])
      @scanner = FrontEnd::Scanner.new(content, error_reporter)
    end

    def parse
      ast = _parse
      interpreter = Interpreter.new(error_reporter, @asset_loader)
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

    def load_mixins
      ast = _parse
      interpreter = MixinParser.new(@asset_loader)
      ast.statements.each do |node|
        interpreter.interpret(node)
      end
    end

    private

    def _parse
      tokens = @scanner.tokenize
      FrontEnd::Parser.new(tokens, error_reporter).parse
    end
  end
end
