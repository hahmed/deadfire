# frozen_string_literal: true

module Deadfire
  class AstPrinter # :nodoc:
    def initialize
      @indentation = 0
    end

    def print(node)
      node.accept(self)
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
        puts "  Declaration: #{declaration}"
      end
    end

    def visit_ruleset_node(node)
      puts "RulesetNode"
      puts "  Selector: #{node.selector}"
      puts "  Block: #{node.block}"
    end
  end
end
