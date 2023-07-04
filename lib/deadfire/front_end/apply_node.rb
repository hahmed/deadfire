# Frozen_string_literal: true

module Deadfire
  class ApplyNode
    attr_reader :mixin_name, :values

    def initialize(mixin_name, values)
      @mixin_name = mixin_name
      @values = values
    end

    def accept(visitor)
      visitor.visit_apply_node(self)
    end
  end
end
