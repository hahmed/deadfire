# Frozen_string_literal: true

module Deadfire
  class Interpreter
    singleton_class.attr_accessor :cached_mixins
    self.cached_mixins = Hash.new { |h, k| h[k] = nil }

    def interpret(node)
      node.accept(self)
    end

    def visit_stylesheet_node(node)
      node.statements.each { |child| child.accept(self) }
    end

    def visit_at_rule_node(node)
      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_declaration_node(node)
      node.accept(self)
    end

    def visit_ruleset_node(node)
      if node.block # && can_cache?(node) TODO: is this node cacheable? There are some rules around what is a mixin
        visit_block_node(node.block)
        Interpreter.cached_mixins[node.selector.mixin_name] = node.block
      end
    end

    def visit_block_node(node)
      node.declarations.each do |declaration|
        case declaration
        when ApplyNode
          apply_mixin(declaration, node)
        when FrontEnd::NestingNode
          apply_nested_rules(declaration, node)
        else
          # declaration.accept(self) we may not need to visit anything we don't process/transform/optimize
        end
      end
    end

    private

    def apply_mixin(declaration, node)
      updated_declarations = []
      declaration.mixin_names.each do |mixin_name|
        if Interpreter.cached_mixins[mixin_name]
          cached_block = Interpreter.cached_mixins[mixin_name]

          # NOTE: remove the left and right brace but we probably don't need to do this, how can this be simplified?
          cached_block.declarations[1...-1].each do |cached_declaration|
            updated_declarations << cached_declaration
          end
        else
          raise "Mixin #{mixin_name} not found" # report instead of raising
        end
      end

      if updated_declarations.any?
        index = node.declarations.index(declaration)
        node.declarations.delete_at(index)
        node.declarations.insert(index, *updated_declarations)
      end
    end

    def apply_nested_rules(declaration, node)
    end
  end
end
