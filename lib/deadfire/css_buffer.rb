# frozen_string_literal: true
require "stringio"

module Deadfire
  class CssBuffer < StringIO
    def initialize(content)
      super(content)
    end

    
  end
end