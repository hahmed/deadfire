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
        when "@" then add_at_keyword
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

      def add_at_keyword(literal = nil)
        selector = [@source[@current]]

        while Spec::CSS_AT_RULES.none? { |kwrd| kwrd == selector.join + peek } && !at_end?
          if peek == "\n"
            break
          end
          selector << advance
        end

        # final char in at-keyword
        selector << advance

        current_keyword = selector.join

        if peek == "\n"
          @line += 1
          @error_reporter.error(@line, "at-keyword cannot be on multiple lines.")
          @tokens << TokenType.new(:at_keyword, current_keyword, literal, @line) # do we add errors like this to tokenizer? I think so
        elsif at_keyword = Spec::CSS_AT_RULES.find { |kwrd| kwrd == current_keyword }
          text = "at_#{at_keyword[1..-1]}"
          @tokens << TokenType.new(text.to_sym, at_keyword, literal, @line)
        else
          @error_reporter.error(@line, "Invalid at-keyword.")
        end
      end

      def peek
        @source[@current + 1] unless at_end?
      end
    end
  end
end
