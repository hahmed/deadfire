# frozen_string_literal: true

module Deadfire
  class DependencyGraph
    singleton_class.attr_accessor :dependencies
    self.dependencies = Hash.new { |h, k| h[k] = [] }

    class << self
      def add(file, dependency)
        unless @dependencies[file].include?(dependency)
          @dependencies[file] << dependency
        end
      end

      def fetch(file)
        @dependencies[file] || []
      end

      def remove(file)
        @dependencies.delete(file)
        @dependencies.each { |key, deps| deps.delete(file) }
      end

      def dependents_of(file)
        @dependencies.select { |key, deps| deps.include?(file) }.keys
      end

      def reset
        @dependencies = Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end