# frozen_string_literal: true
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
      node.value.each do |value|
        @output << value.lexeme
      end

      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_ruleset_node(node)
      @output << node.selector.selector
      @output << " "

      visit_block_node(node.block)
    end

    def visit_block_node(node)
      node.declarations.each do |declaration|
        case declaration
        when ApplyNode
          visit_apply_node(declaration)
        when FrontEnd::BlockNode
          visit_block_node(declaration)
        when FrontEnd::AtRuleNode
          visit_at_rule_node(declaration)
        else
          @output << declaration.lexeme
        end
      end
    end

    def visit_newline_node(node)
      @output << node.text
    end

    def visit_apply_node(node)
      @output << node.node.lexeme
    end

    def visit_comment_node(node)
      @output << node.comment.lexeme unless Deadfire.configuration.compressed
    end
  end
end
