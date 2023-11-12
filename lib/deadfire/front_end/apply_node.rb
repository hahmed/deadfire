# Frozen_string_literal: true

module Deadfire
  class ApplyNode
    attr_reader :node, :mixin_names

    def initialize(node, mixin_names)
      # TODO: mixin name can be single or multiple names, separated by a comma
      @node = node
      @mixin_names = fetch_mixin_name_from(mixin_names)
    end

    def accept(visitor)
      visitor.visit_apply_node(self)
    end

    def lineno
      node.lineno
    end

    private

    def fetch_mixin_name_from(tokens)
      @_cached_mixin_name ||= begin
        names = []
        current = []
        tokens.each do |token|
          case token.type
          when :comma
            names << current.join("")
            current = []
            current << token.lexeme
          when :whitespace
            # ignore whitespace
          else
            current << token.lexeme
          end
        end
        names << current.join("")
        names
      end
    end
  end
end
