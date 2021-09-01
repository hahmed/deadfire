# frozen_string_literal: true

module Deadfire
  class Engine
    def call(input)
      { data: Parser.call(input) }
    end
  end
end