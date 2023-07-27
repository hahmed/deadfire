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

    def visit_ruleset_node(node)
      @output << node.selector.selector
      @output << " "

      visit_block_node(node.block)
    end

    def visit_block_node(node)
      node.declarations.each do |declaration|
        case declaration
        when FrontEnd::NestingNode
          visit_nesting_node(declaration)
        when ApplyNode
          visit_apply_node(declaration)
        when FrontEnd::BlockNode
          visit_block_node(declaration)
        else
          @output << declaration.lexeme
        end
      end
    end

    # I don't like this here, do we merge the generator and interpreter?
    # or the node is transformed into a declaration node, because interpreting is finished
    # and here we can focus on generating the css
    def visit_nesting_node(node)
      @output << node.property.lexeme
      @output << " "
      @output << node.lexeme
      @output << " "

      visit_block_node(node.block)
    end

    def visit_apply_node(node)
      @output << node.node.lexeme
    end

    def visit_comment_node(node)
      @output << node.comment.lexeme if Deadfire.configuration.keep_comments
    end
  end
end
