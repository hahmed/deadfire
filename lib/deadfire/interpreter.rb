# frozen_string_literal: true

module Deadfire
  class Interpreter # :nodoc:
    def initialize(error_reporter, asset_loader)
      @error_reporter = error_reporter
      @asset_loader = asset_loader
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

        unless @asset_loader.cached_css(node.selector.selector)
          @asset_loader.cache_css(node.selector.selector, node.block) if node.selector.cacheable?
        end
      end
    end

    def visit_block_node(node, parent)
      node.declarations.each do |declaration|
        case declaration
        when ApplyNode
          apply_mixin(declaration, node)
        else
          # we may not need to visit this as we don't process/transform/optimize
        end
      end
    end

    def visit_comment_node(node)
      # node.accept(self)
    end

    def visit_apply_node(node)
      # do nothing for now
    end

    def visit_newline_node(node)
    end

    private

    def apply_mixin(mixin, node)
      updated_declarations = []
      mixin.mixin_names.each do |mixin_name|
        if cached_block = @asset_loader.cached_css(mixin_name)
          # NOTE: remove the left and right brace but we probably don't need to do this, how can this be simplified?
          cached_block.declarations[1...-1].each do |cached_declaration|
            updated_declarations << cached_declaration
          end
          updated_declarations.shift if updated_declarations.first.type == :newline
          updated_declarations.pop if updated_declarations.last.type == :newline
        else
          @error_reporter.error(mixin.lineno, "Mixin #{mixin_name} not found") # TODO: we need the declarations lineno, not the block
        end
      end

      if updated_declarations.any?
        index = node.declarations.index(mixin)
        node.declarations.delete_at(index)
        node.declarations.insert(index, *updated_declarations)
      end
    end
  end
end
