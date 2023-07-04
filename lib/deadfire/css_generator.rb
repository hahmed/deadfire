# Frozen_string_literal: true
require "stringio"

module Deadfire
  class CssGenerator # :nodoc:
    def initialize(tree)
      @tree = tree
      @output = StringIO.new # TODO: write to file instead of string buffer in temp folder
    end

    def generate
      @tree.accept(self)
      @output.string
    end

    def visit_stylesheet_node(node)
      node.statements.each { |child| child.accept(self) }.join("\n")
    end

    def visit_at_rule_node(node)
      @output << node.at_keyword.lexeme
      @output << " "
      node.value.each do |value|
        @output << value.lexeme
      end

      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_block_node(node)
      node.declarations.each do |declaration|
        @output << declaration.lexeme
      end
    end

    def visit_ruleset_node(node)
      @output << node.selector.selector
      @output << " "

      visit_block_node(node.block)
    end
  end
end
