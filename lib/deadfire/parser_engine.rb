module Deadfire
  class ParserEngine
    attr_reader :error_reporter, :tokens, :options, :current

    def initialize(content, options = {})
      @error_reporter = ErrorReporter.new
      @tokens = []
      @options = {}
      @current = 0
      @scanner = FrontEnd::Scanner.new(content, error_reporter)
      @statements = []
    end

    def parse
      tokens = @scanner.tokenize

      # tokens.each do |token|
      #   puts token.inspect
      # end

      # write some code to group tokens into statements
      ast = FrontEnd::Parser.new(tokens, error_reporter).parse

      printer = AstPrinter.new
      ast.each do |node|
        printer.print(node)
      end
    end

    def errors?
      @error_reporter.errors?
    end
  end
end
