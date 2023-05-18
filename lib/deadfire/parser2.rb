module Deadfire
  class Parser2
    attr_reader :error_reporter

    def initialize
      @error_reporter = ErrorReporter.new
    end

    TEST_CSS = <<~CSS
      @media screen and (min-width: 480px) {
        .foo {
          color: red;
        }
      }
    CSS

    def parse(content, options = {})
      scanner = Scanner.new(content, @error_reporter)
      tokens = scanner.scan_tokens

      tokens.each do |token|
        puts token
      end
    end

    def errors?
      @error_reporter.errors?
    end

    class Scanner
      def initialize(source, error_reporter)
        @source = source
        @total_chars = @source.length
        @tokens = []
        @start = 0
        @current = 0
        @line = 1
        @error_reporter = error_reporter
      end

      def scan_tokens
        until at_end?
          @start = @current
          scan_token
        end

        @tokens << TokenType.new(:eof, "", nil, @line)
      end

      private

      TokenType = Struct.new(:type, :lexeme, :literal, :line)

      def at_end?
        @current >= @total_chars
      end

      def scan_token
        case advance
        when "@" then add_token(at_selector)
        when "{" then add_token(:left_brace)
        when "}" then add_token(:right_brace)
        when "#" then add_token(:id_selector)
        when "." then add_token(:class_selector)
        when ":" then add_token(:pseudo_selector)
        when ";" then add_token(:semicolon)
        when "," then add_token(:comma)
        when "(" then add_token(:left_paren)
        when ")" then add_token(:right_paren)
        when "[" then add_token(:left_bracket)
        when "]" then add_token(:right_bracket)
        when "=" then add_token(:equal)
        when "~" then add_token(:tilde)
        when "+" then add_token(:plus)
        when ">" then add_token(:greater_than)
        when "\n" then @line += 1
        else
          @error_reporter.error(@line, "Unexpected character.")
        end
      end

      def advance
        @current += 1
        @source[@current]
      end

      def add_token(type, literal = nil)
        text = @source[@start...@current]
        @tokens << TokenType.new(type, text, literal, @line)
      end

      def at_selector
        selector = [@source[@current]]
        # do I look ahead 13 chars and see if any matches, then move the current pointer forward that many chars?

        selector << @source[@current + 1..@current + Spec::MIN_AT_RULE_LENGTH]

        # peek next char and add to selector if selector matches at rule then return otherwise keep going
        while peek && Spec::CSS_AT_RULES.include?(selector.join)
          selector << advance
        end

        if Spec::CSS_AT_RULES.include?(selector.join)
          :at_selector
        else
          @current += 1
          peek = @source[@current + 1]
        end
      end

      def peek
        @source[@current] unless at_end?
      end
    end
  end
end
