# frozen_string_literal: true

module Deadfire
  class AstPrinter # :nodoc:
    def initialize
      @indentation = 0
    end

    def print(node)
      node.accept(self)
    end

    def visit_stylesheet_node(node)
      puts "StylesheetNode"
      node.statements.each do |statement|
        # something
      end
    end

    def visit_at_rule_node(node)
      puts "AtRuleNode"
      puts "  AtKeyword: #{node.at_keyword.lexeme}"
      node.value.each do |value|
        puts "  Value: #{value}"
      end
      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_block_node(node)
      puts "BlockNode"
      node.declarations.each do |declaration|
        case declaration
        when FrontEnd::Token
          puts "  Declaration: #{declaration.lexeme}"
        when FrontEnd::AtRuleNode
          visit_at_rule_node(declaration)
        when FrontEnd::RulesetNode
          visit_ruleset_node(declaration)
        end
      end
    end

    def visit_ruleset_node(node)
      puts "RulesetNode"
      puts "  Selector: #{node.selector}"
      if node.block
        visit_block_node(node.block)
      end
    end

    def visit_comment_node(node)
      puts "CommentNode"
      puts "  Comment: #{node.comment.lexeme}"
    end
  end
end
