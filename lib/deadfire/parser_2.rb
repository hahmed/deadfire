module Deadfire
  class Parser2
    def initialize
      @errors = []
    end

    def parse(content, options = {})
      scanner = Scanner.new(content)
      tokens = scanner.scan_tokens

      tokens.each do |token|
        puts token
      end
    end

    # create error struct with line and message
    Error = Struct.new(:line, :message)

    def error(line, message)
      @errors << Error.new(line, message)
    end

    def errors?
      @errors.any?
    end

    TokenType = Struct.new(:type, :lexeme, :literal, :line)

    class Scanner
      def initialize(source)
        @source = source
        @tokens = []
        @start = 0
        @current = 0
        @line = 1
      end

      def scan_tokens
        until at_end?
          @start = @current
          scan_token
        end

        @tokens << TokenType.new(:eof, "", nil, @line)
      end

      private

      def at_end?
        @current >= @source.length
      end

      def scan_token
        case advance
        when "@" then add_token(at_selector_match)
        when "{" then add_token(:left_brace)
        when "}" then add_token(:right_brace)
        when "#" then add_token(:id_selector)
        when "." then add_token(:class_selector)
        else
          error(@line, "Unexpected character.")
        end
      end

      def advance
        @source[@current += 1]
      end

      def add_token(type, literal = nil)
        text = @source[@start...@current]
        @tokens << TokenType.new(type, text, literal, @line)
      end

      def at_selector_match
        selector = [@source[@current]]

        # peek next char and add to selector if selector matches at rule then return otherwise keep going
        while peek && Spec::CSS_AT_RULES.include?(selector.join)
          selector << advance
        end

        if Spec::CSS_AT_RULES.include?(selector.join)
          :at_selector
        else
          peek = @source[@current + 1]
        end
      end
    end
  end
end
