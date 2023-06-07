module Deadfire
  class AstPrinter
    def initialize
      @indentation = 0
    end

    def print(node)
      node.accept(self)
    end

    def visit_at_rule_node(node)
      puts "AtRuleNode"
      puts "  AtKeyword: #{node.at_keyword.literal}"
      node.value.each do |value|
        puts "  Value(s): #{value.literal}"
      end
      puts "  Block: #{node.block}" if node.block
    end

    def visit_ruleset_node(node)
      puts "RulesetNode"
      puts "  Selector: #{node.selector}"
      puts "  Block: #{node.block}"
    end
  end
end
