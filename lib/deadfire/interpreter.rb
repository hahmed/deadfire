# Frozen_string_literal: true

module Deadfire
  class Interpreter
    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = nil }

    def initialize(tree)
      @tree = tree
    end

    def interpret
      @tree.accept(self)
      @tree
    end

    private

    def visit_stylesheet_node(node)
      node.statements.each { |child| child.accept(self) }
    end

    def visit_at_rule_node(node)
      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_ruleset_node(node)
      # TODO: we will need to cache this ruleset node, so we can handle @apply
      # In this method we execute @apply + nesting rules
      if node.block # && can_cache?(node)
        visit_block_node(node.block)
        Interpreter.cached_mixins[node.selector.mixin_name] = node.block
      end
    end


    def visit_block_node(node)
      node.declarations.each do |declaration|
        if declaration.is_a?(ApplyNode)
          apply_mixin(declaration, node)
        else
          declaration.accept(self)
        end
      end
    end

    def apply_mixin(declaration, node)
      mixin_name = declaration.mixin_name
      if cached_mixins[mixin_name]
        cached_block = cached_mixins[mixin_name]
        index = node.declarations.index(declaration)
        node.declarations.delete_at(index)
        node.declarations.insert(index, cached_block.declarations)
      else
        raise "Mixin #{mixin_name} not found"
      end
    end
  end
end
