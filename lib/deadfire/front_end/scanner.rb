# frozen_string_literal: true
module Deadfire
  module FrontEnd
    # TODO: the lexemes are not printing out the correct value, they have spaces in front end and \ too.
    # type=:semicolon, lexeme="\";", literal=nil
    # type=:string, lexeme=" \"UTF-8\"", literal=" \"UTF-8",
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

      NEWLINE = "\n"

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
        when "<" then add_token(:less_than)
        when "*" then add_token(:asterisk)
        when "^" then add_token(:caret)
        when "$" then add_token(:dollar)
        when "|" then add_token(:pipe)
        when "!" then add_token(:exclamation)
        when "-" then add_token(:minus)
        when "/" then add_token(:slash)
        when "&" then add_token(:ampersand)
        when "'" then add_token(:single_quote)
        when NEWLINE then @line += 1
        when " ", "\r", "\t" # Ignore whitespace.
        when '"' then add_string_token
        else
          if digit?(current_char)
            add_number_token
          else
            @error_reporter.error(@line, "Unexpected character.")
          end
        end
      end

      def advance
        @current += 1
        @source[@current]
      end

      def add_token(type, literal = nil)
        text = @source[@start..@current]
        @tokens << TokenType.new(type, text, literal, @line)
      end

      def add_at_keyword(literal = nil)
        selector = [@source[@current]]

        while Spec::CSS_AT_RULES.none? { |kwrd| kwrd == selector.join + peek } && !at_end?
          break if peek == NEWLINE
          selector << advance
        end

        # final char in at-keyword
        selector << advance

        current_keyword = selector.join
        at_keyword = Spec::CSS_AT_RULES.find { |kwrd| kwrd == current_keyword }

        if peek == NEWLINE
          @line += 1
          @error_reporter.error(@line, "at-keyword cannot be on multiple lines.")
          add_token(:at_keyword, current_keyword)
        elsif at_keyword
          text = "at_#{at_keyword[1..-1]}"
          add_token(text.to_sym, at_keyword)
        else
          @error_reporter.error(@line, "Invalid at-keyword.")
        end
      end

      def add_string_token
        while peek != '"' && !at_end?
          @line += 1 if peek == NEWLINE
          advance
        end

        if at_end?
          @error_reporter.error(@line, "Unterminated string.")
          return
        end

        advance

        # Trim the surrounding quotes.
        # this does not look right... page 50 crafting interpreters.
        value = @source[@start + 2..@current - 1]
        add_token(:string, value)
      end

      def add_number_token
        while digit?(peek)
          advance
        end

        # Look for a fractional part.
        if peek == "." && digit?(peek_next)
          # Consume the "."
          advance

          while digit?(peek)
            advance
          end
        end

        add_token(:number, @source[@start..@current].to_f)
      end

      def peek
        @source[@current + 1] unless at_end?
      end

      def current_char
        @source[@current]
      end

      def peek_next
        @source[@current + 2] unless at_end?
      end

      def digit?(char)
        char && char >= "0" && char <= "9"
      end
    end
  end
end
