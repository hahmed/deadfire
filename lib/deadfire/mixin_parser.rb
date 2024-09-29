# frozen_string_literal: true

module Deadfire
  class MixinParser # :nodoc:
    def initialize
      @mixins = {}
    end

    def interpret(node)
      node.accept(self)
    end

    def visit_stylesheet_node(node)
      node.statements.each { |child| child.accept(self) }
    end

    def visit_at_rule_node(node)
      if node.block
        visit_block_node(node.block, node)
      end
    end

    def visit_ruleset_node(node)
      if node.block
        visit_block_node(node.block, node)

        unless @mixin.key?(node.selector.selector)
          @mixin[node.selector.selector] = node.block if node.selector.cacheable?
        end
      end
    end

    def visit_block_node(node, parent)
    end

    def visit_comment_node(node)
    end

    def visit_apply_node(node)
    end

    def visit_newline_node(node)
    end
  end
end
