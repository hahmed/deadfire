# frozen_string_literal: true

module Deadfire
  module FrontEnd
    class PropertyNode < BaseNode
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def accept(visitor)
        visitor.visit_property_node(self)
      end
    end
  end
end
