# frozen_string_literal: true

module Deadfire
  module FrontEnd
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

      def tokenize
        until at_end?
          @start = @current - 1
          scan_token
        end

        @tokens << Token.new(:eof, "", nil, @line)
      end

      private

      NEWLINE = "\n"

      def at_end?
        @current >= @total_chars
      end

      def scan_token
        token = advance
        case token
        when "@" then add_at_rule
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
        when "-" then add_hypen_token
        when "/" then add_token(:slash)
        when "&" then add_token(:ampersand)
        when "'" then add_token(:single_quote)
        when NEWLINE then @line += 1
        when " ", "\r", "\t" # Ignore whitespace.
        when '"' then add_string_token
        # when nil then ;# TODO: I think there is a null added somewhere, which we ignore for now.
        else
          if digit?(token)
            add_number_token
          elsif text?(token)
            add_text_token # or word token?
          else
            @error_reporter.error(@line, "Unexpected character.")
          end
        end
      end

      def add_token(type, literal = nil)
        text = @source[@start + 1..current_char_position]
        @tokens << Token.new(type, text, literal, @line)
      end

      def add_at_rule(literal = nil)
        selector = [current_char]

        while Spec::CSS_AT_RULES.none? { |kwrd| kwrd == selector.join + peek } && !at_end?
          break if peek == NEWLINE
          selector << advance
        end

        # final char in at-rule
        selector << advance

        current_at_rule = selector.join
        at_rule = Spec::CSS_AT_RULES.find { |kwrd| kwrd == current_at_rule }

        if peek == NEWLINE
          @line += 1
          @error_reporter.error(@line, "at-rule cannot be on multiple lines.")
          add_token(:at_rule, current_at_rule)
        elsif at_rule
          text = "at_#{at_rule[1..-1]}"
          add_token(:at_rule, text)
        else
          @error_reporter.error(@line, "Invalid at-rule.")
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
        # TODO: this does not look right... page 50 crafting interpreters.
        value = @source[@start + 2..current_char_position]
        add_token(:string, value)
      end

      # This token is very similar to the string token, but we want to explicitly
      # split up text from string, because string in css is surrounded by quotes and text is free form
      # which can be a property or value e.g. `color: red;`.
      def add_text_token
        while text?(peek) && !at_end?
          advance
        end

        value = @source[@start..current_char_position]
        add_token(:text, value)
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

      def add_hypen_token
        if peek == "-"
          advance
          add_token(:double_hyphen)
        else
          add_token(:hyphen)
        end
      end

      def current_char_position
        @current - 1
      end

      def current_char
        @source[current_char_position]
      end

      def advance
        @current += 1
        current_char
      end

      def peek
        @source[@current] unless at_end?
      end

      def peek_next
        @source[@current + 1] unless at_end?
      end

      def digit?(char)
        char >= "0" && char <= "9"
      end

      def text?(char)
        (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
      end
    end
  end
end